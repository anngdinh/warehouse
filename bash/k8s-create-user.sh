#!/bin/bash

set -e  # Exit on error

USER=test-user-2

# Create directory
mkdir -p $USER

# Generate private key
openssl genrsa -out $USER/$USER.key 2048

# Generate CSR
openssl req -new -key $USER/$USER.key -out $USER/$USER.csr -subj "/CN=$USER"

# Convert CSR to base64
CSR_CONTENT=$(cat $USER/$USER.csr | base64 | tr -d '\n')

# Create CSR resource
cat <<EOF > $USER/$USER-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $USER-csr
spec:
  request: $CSR_CONTENT
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

# Clean up old CSR if exists
kubectl delete csr $USER-csr --ignore-not-found

# Create and approve CSR
kubectl create -f $USER/$USER-csr.yaml
kubectl certificate approve $USER-csr

# Wait for certificate to be issued
echo "Waiting for certificate to be issued..."
kubectl wait --for=condition=Approved csr/$USER-csr --timeout=30s

# Get certificate
kubectl get csr $USER-csr -o jsonpath='{.status.certificate}' | base64 --decode > $USER/$USER.crt

# Get cluster info
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')

# Create temporary file for CA cert
kubectl config view --raw --minify -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode > $USER/ca.crt

# Create kubeconfig
kubectl config set-cluster $CLUSTER_NAME \
  --server=$SERVER \
  --certificate-authority=$USER/ca.crt \
  --embed-certs=true \
  --kubeconfig=$USER/$USER.kubeconfig

kubectl config set-credentials $USER \
  --client-certificate=$USER/$USER.crt \
  --client-key=$USER/$USER.key \
  --embed-certs=true \
  --kubeconfig=$USER/$USER.kubeconfig

kubectl config set-context $USER-context \
  --cluster=$CLUSTER_NAME \
  --namespace=default \
  --user=$USER \
  --kubeconfig=$USER/$USER.kubeconfig

kubectl config use-context $USER-context --kubeconfig=$USER/$USER.kubeconfig

# Clean up temporary CA file
rm -f $USER/ca.crt

# Create readonly ClusterRole
cat <<EOF > $USER/$USER-cluster-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: $USER-readonly
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
- nonResourceURLs: ["*"]
  verbs: ["get", "list"]
EOF

# Create ClusterRoleBinding for cluster-wide access
cat <<EOF > $USER/$USER-cluster-role-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: $USER-readonly-binding
subjects:
- kind: User
  name: $USER
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: $USER-readonly
  apiGroup: rbac.authorization.k8s.io
EOF

# Apply RBAC
kubectl apply -f $USER/$USER-cluster-role.yaml
kubectl apply -f $USER/$USER-cluster-role-binding.yaml

# Clean up CSR
kubectl delete csr $USER-csr --ignore-not-found

# Test access
echo "Testing readonly access..."
kubectl --kubeconfig=$USER/$USER.kubeconfig get pods --all-namespaces

echo "Testing write access (should fail)..."
kubectl --kubeconfig=$USER/$USER.kubeconfig create namespace test-ns 2>&1 || echo "Write access correctly denied"

echo "Kubeconfig created: $USER/$USER.kubeconfig"