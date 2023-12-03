# Bash helpful

Debug disk usage

```bash
du -sh /var/* -h
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
#!/bin/bash
if [ -z "$1" ] ||[ -z "$2" ]
then
  read -p "Username: " NAME
  read -p "Publickey: " PUBKEY
else
  NAME=$1
  PUBKEY=$2
fi
echo "Creating and adding permission for user $NAME"
sudo adduser --shell /bin/bash --gecos "" --disabled-password $NAME
sudo -u $NAME mkdir -p /home/$NAME/.ssh
sudo -u $NAME echo $PUBKEY > /home/$NAME/.ssh/authorized_keys
sudo -i echo "$NAME ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/$NAME
```
