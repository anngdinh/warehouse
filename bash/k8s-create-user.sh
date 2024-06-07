#!/bin/bash
# https://hbayraktar.medium.com/how-to-create-a-user-in-a-kubernetes-cluster-and-grant-access-bfeed991a0ef
# https://aungzanbaw.medium.com/a-step-by-step-guide-to-creating-users-in-kubernetes-6a5a2cfd8c71

USER=stt

mkdir -p $USER
openssl genrsa -out $USER/$USER.key 2048
openssl req -new -key $USER/$USER.key -out $USER/$USER.csr -subj "/CN=$USER"

CSR_CONTENT=$(cat $USER/$USER.csr | base64 | tr -d '\n')

# echo $CSR_CONTENT

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

kubectl delete CertificateSigningRequest $USER-csr
kubectl create -f $USER/$USER-csr.yaml
kubectl certificate approve $USER-csr
kubectl get csr $USER-csr -o jsonpath='{.status.certificate}' | base64 --decode > $USER/$USER.crt

# get server endpoint
server=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
ca_cert=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

kubectl config set-cluster kubernetes --server=$server --certificate-authority=$USER/$USER.crt --embed-certs=true --kubeconfig=$USER/$USER.kubeconfig

# current_ca=$(kubectl config view --kubeconfig=$USER/$USER.kubeconfig -o jsonpath='{.clusters[0].cluster.certificate-authority}')
current_ca=$(cat $USER/$USER.crt | base64 | tr -d '\n')

sed -i "s/$current_ca/$ca_cert/g" $USER/$USER.kubeconfig

# Set Credentials for Developer:
kubectl config set-credentials $USER --client-certificate=$USER/$USER.crt --client-key=$USER/$USER.key --embed-certs=true --kubeconfig=$USER/$USER.kubeconfig
# Set Developer Context: 
kubectl config set-context $USER-context --cluster=kubernetes --namespace=default --user=$USER --kubeconfig=$USER/$USER.kubeconfig
# Use Developer Context:
kubectl config use-context $USER-context --kubeconfig=$USER/$USER.kubeconfig

kubectl --kubeconfig=$USER/$USER.kubeconfig get pods


cat <<EOF > $USER/$USER-cluster-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: $USER-role
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
EOF


cat <<EOF > $USER/$USER-role-binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $USER-binding
  namespace: default
subjects:
- kind: User
  name: $USER
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: $USER-role
  apiGroup: rbac.authorization.k8s.io
EOF


kubectl apply -f $USER/$USER-cluster-role.yaml -f $USER/$USER-role-binding.yaml

kubectl --kubeconfig=$USER/$USER.kubeconfig get pods