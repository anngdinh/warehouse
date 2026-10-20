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

### Zshrc

```sh
export PATH="$HOME/.local/bin:$PATH"
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

alias docker=podman
alias k=kubecolor

# --- Line-editing parity with VS Code's terminal ---------------------
bindkey -e   # emacs keymap (zsh default unless $EDITOR/$VISUAL is vi)

# Word boundaries: default WORDCHARS includes '-' so "hello-world" is ONE
# word. Trim it so -, ., / act as word boundaries (word ops stop at them).
WORDCHARS='_'
# (use WORDCHARS='' to split on every punctuation, closest to VS Code's editor)

# Word motion / deletion — bind BOTH the Meta form (what ~/.wezterm.lua
# sends) and the xterm CSI form, so it works regardless of the sequence.
bindkey '\eb'     backward-word        # Option+Left
bindkey '\ef'     forward-word         # Option+Right
bindkey '^[[1;3D' backward-word        # Option+Left (CSI form)
bindkey '^[[1;3C' forward-word         # Option+Right (CSI form)
bindkey '\e^?'    backward-kill-word   # Option+Backspace
bindkey '\ed'     kill-word            # Option+fn+Delete (forward)
bindkey '^W'      backward-kill-word   # Ctrl+W

# Up/Down: search history by what's already typed ("claude" + Up → only claude…)
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search     # Up   (normal mode)
bindkey '^[OA' up-line-or-beginning-search     # Up   (application mode)
bindkey '^[[B' down-line-or-beginning-search   # Down
bindkey '^[OB' down-line-or-beginning-search
setopt HIST_IGNORE_ALL_DUPS   # no repeated entries while stepping through

# zsh-autosuggestions: Option+Right (forward-word) accepts ONE word of the
# suggestion at a time; full-accept stays on End / Ctrl+E.
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(forward-word emacs-forward-word vi-forward-word)

# --- zsh-syntax-highlighting -----------------------------------------
# MUST be sourced LAST — it wraps the ZLE line editor, so anything that
# defines widgets/bindings (incl. zsh-autosuggestions above) has to load first.
# Highlighters (set BEFORE the source line): main = syntax, brackets = match/mismatch.
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# awake on|off|status: keep Mac from sleeping (screen still locks)
awake() {
  local p=~/Library/LaunchAgents/local.caffeinate.plist
  case $1 in
    on)  launchctl bootstrap gui/$UID $p 2>/dev/null; echo "awake: on" ;;
    off) launchctl bootout gui/$UID/local.caffeinate 2>/dev/null; echo "awake: off" ;;
    *)   launchctl print gui/$UID/local.caffeinate &>/dev/null && echo "awake: on" || echo "awake: off" ;;
  esac
}
```

### .claude/statusline-command.sh

```
#!/bin/bash
# Claude Code status line: model name + context usage + git branch

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
# Drop any trailing parenthetical, e.g. "Opus 5 (1M context)" -> "Opus 5"
model=$(echo "$model" | sed -E 's/ *\(.*\)$//')
tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
exceeds=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
chat=$(echo "$input" | jq -r '.session_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
# Remote Control: the statusline payload's .remote key only appears on sessions
# *driven* from the remote side, not local sessions publishing themselves. The
# live signal is the bridge id in ~/.claude/sessions/<pid>.json.
# ponytail: greps the session dir by session_id; switch to $PPID if it gets slow.
weekly=$(echo "$input" | jq -r '.rate_limits.seven_day | if . then "\(.used_percentage) \(.resets_at)" else empty end')

sid=$(echo "$input" | jq -r '.session_id // empty')
remote=false
if [ -n "$sid" ]; then
  sf=$(grep -lF "\"$sid\"" "$HOME"/.claude/sessions/*.json 2>/dev/null | head -1)
  [ -n "$sf" ] && jq -e '.bridgeSessionId' "$sf" >/dev/null 2>&1 && remote=true
fi


branch=""
if [ -n "$dir" ]; then
  branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

# Colors
C_CHAT="\033[38;5;170m"   # magenta
C_MODEL="\033[38;5;39m"   # cyan/blue
C_EFFORT="\033[38;5;214m" # orange
C_CTX="\033[38;5;180m"    # amber
C_CTX_HI="\033[38;5;203m" # red (over 200k)
C_BRANCH="\033[38;5;114m" # green
C_DIR="\033[1;38;5;250m"  # bold gray
C_REMOTE_ON="\033[38;5;46m"  # bright green
C_REMOTE_OFF="\033[2m"       # dim
C_WEEK_SAFE="\033[38;5;40m"  # deep green - 10+ pts under pace
C_WEEK_OK="\033[38;5;114m"   # green  - at or under pace
C_WEEK_EDGE="\033[38;5;220m" # yellow - up to 5 pts ahead of pace
C_WEEK_WARN="\033[38;5;214m" # orange - 5-10 pts ahead of pace
C_WEEK_HOT="\033[38;5;203m"  # red    - 10+ pts ahead of pace
C_DIM="\033[2m"           # dim separators
RESET="\033[0m"

out=$(printf "${C_MODEL}%s${RESET}" "$model")
if [ -n "$chat" ]; then
  out=$(printf "${C_CHAT}%s${RESET} ${C_DIM}|${RESET} ${C_MODEL}%s${RESET}" "$chat" "$model")
fi
if [ -n "$effort" ]; then
  out=$(printf "%b ${C_EFFORT}[%s]${RESET}" "$out" "$effort")
fi
if [ -n "$tokens" ] && [ "$tokens" -gt 0 ]; then
  ctx=$(awk -v t="$tokens" 'BEGIN{ if (t>=1000) printf "%.0fk", t/1000; else printf "%d", t }')
  ctx_color="$C_CTX"
  [ "$exceeds" = "true" ] && ctx_color="$C_CTX_HI"
  out=$(printf "%b ${C_DIM}|${RESET} ${ctx_color}%s${RESET}" "$out" "$ctx")
fi
if [ -n "$branch" ]; then
  out=$(printf "%b ${C_DIM}|${RESET} ${C_BRANCH}\xee\x82\xa0 %s${RESET}" "$out" "$branch")
fi
if [ -n "$dir" ]; then
  out=$(printf "%b\n${C_DIR}\xf0\x9f\x93\x81 %s${RESET}" "$out" "$(basename "$dir")")
fi
if [ "$remote" = "true" ]; then
  out=$(printf "%b ${C_DIM}|${RESET} ${C_REMOTE_ON}\xf0\x9f\x93\xa1 RC${RESET}" "$out")
elif [ "$remote" = "false" ]; then
  out=$(printf "%b ${C_DIM}|${RESET} ${C_REMOTE_OFF}RC off${RESET}" "$out")
fi
# Show ELAPSED time in the window (len - remaining) so % and time grow together.
# Colour by pace, not raw %: compare used % against % of the window elapsed.
# ponytail: flat percentage-point margins, swap for a ratio if it reads wrong.
for spec in "$weekly|604800|"; do
  IFS='|' read -r w len label <<< "$spec"
  [ -n "$w" ] || continue
  res=$(awk -v w="$w" -v len="$len" -v now="$(date +%s)" 'BEGIN{
    split(w, a, " "); left = a[2] - now
    if (left < 0) left = 0; if (left > len) left = len
    s = len - left
    d = int(s/86400); h = int((s%86400)/3600); m = int((s%3600)/60)
    t = (d > 0) ? d "d" h "h" : ((h > 0) ? h "h" m "m" : m "m")
    e = s / len * 100
    g = a[1] - e
    p = (g <= -10) ? "safe" : (g <= 0) ? "ok" : (g <= 5) ? "edge" : (g <= 10) ? "warn" : "hot"
    printf "%d%% / %s %s", a[1], t, p
  }')
  pace=${res##* }; txt=${res% *}
  case "$pace" in
    safe) wk_color="$C_WEEK_SAFE" ;;
    ok)   wk_color="$C_WEEK_OK" ;;
    edge) wk_color="$C_WEEK_EDGE" ;;
    warn) wk_color="$C_WEEK_WARN" ;;
    *)    wk_color="$C_WEEK_HOT" ;;
  esac
  out=$(printf "%b ${C_DIM}|${RESET} ${wk_color}\xe2\x8f\xb3 %s%s${RESET}" "$out" "$label" "$txt")
done

printf "%b" "$out"
```
