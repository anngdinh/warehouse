# Bash helpful

Debug disk usage

```bash
du -sh /var/* -h

# clear docker disk usage
docker system prune -a
```

Debug process usage

```bash
# top interval
pidstat -h -r -u -v -p ___pid___ __interval__

# top by process name
top -p $(pgrep -d, -f "go run main.go")
```

Add user

```bash
#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root or with sudo"
  exit 1
fi

if [[ $# -lt 2 ]]; then
  read -rp "Username: " NAME
  read -rp "Public key: " PUBKEY
else
  NAME="$1"
  PUBKEY="$2"
fi

HOME_DIR="/home/$NAME"
SSH_DIR="$HOME_DIR/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
SUDOERS_FILE="/etc/sudoers.d/$NAME"

echo "Creating user: $NAME"

# Create user if not exists
if id "$NAME" &>/dev/null; then
  echo "User already exists"
else
  adduser \
    --shell /bin/bash \
    --gecos "" \
    --disabled-password \
    "$NAME"
fi

# Setup SSH
mkdir -p "$SSH_DIR"

echo "$PUBKEY" > "$AUTHORIZED_KEYS"

# Permissions
chown -R "$NAME:$NAME" "$SSH_DIR"
chmod 700 "$SSH_DIR"
chmod 600 "$AUTHORIZED_KEYS"

# Passwordless sudo
echo "$NAME ALL=(ALL:ALL) NOPASSWD: ALL" > "$SUDOERS_FILE"
chmod 440 "$SUDOERS_FILE"

# Validate sudoers
visudo -cf "$SUDOERS_FILE"

echo "================================="
echo "User created successfully"
echo "Username: $NAME"
echo "Home: $HOME_DIR"
echo "================================="
```

## K8S

[Create user](./k8s-create-user.sh)

## Helm

```bash
helm dependency update
helm package .

helm repo remove hub-cls && helm repo add hub-cls http://localhost:8088
helm cm-push -f charts/node-agent/node-agent-0.1.51.tgz hub-cls

helm repo update coroot
helm install --namespace coroot coroot coroot/coroot

helm list -n coroot
helm uninstall -n coroot coroot
helm repo update
helm install --namespace coroot coroot hub-cls/coroot
```

## Install

### Golang

```bash
curl -OL https://go.dev/dl/go1.22.4.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.4.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
go version
```

### Velero
  
```bash
curl -OL https://github.com/vmware-tanzu/velero/releases/download/v1.13.2/velero-v1.13.2-linux-amd64.tar.gz
tar -xvf velero-v1.13.2-linux-amd64.tar.gz
cp velero-v1.13.2-linux-amd64/velero /usr/local/bin
```

### Kubecolor

```bash
curl -OL https://github.com/kubecolor/kubecolor/releases/download/v0.3.3/kubecolor_0.3.3_linux_amd64.tar.gz
tar -xvf kubecolor_0.3.3_linux_amd64.tar.gz
cp kubecolor /usr/local/bin
echo 'alias k=kubecolor' >> ~/.bashrc
```

### kubectl x86-64

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

### Kubectl node-shell

```bash
curl -LO https://github.com/kvaps/kubectl-node-shell/raw/master/kubectl-node_shell
chmod +x ./kubectl-node_shell
sudo mv ./kubectl-node_shell /usr/local/bin/kubectl-node_shell
```
