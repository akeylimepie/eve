printLogo

isLinux

if [ "$USER_ID" != 0 ]; then
  printError "Initial setup must be run as sudo"
  exit 1
fi

if [ -v iptables ] && [ "$iptables" = "cloudflare" ]; then
  tuneIptabes
  exit 0
fi

authorized_key_exists=false

grep -qE "^app:" /etc/group
if [ $? -ne 0 ]; then
  groupadd app
fi

mkdir -p /srv/app
chgrp app /srv/app
chmod 775 /srv/app

if [ -n "$user" ]; then
  addUser $user
fi

if [ -n "$deploy" ]; then
  addDeployUser $deploy
fi

if [ $authorized_key_exists ]; then
  tuneSSH true
else
  tuneSSH false
fi
