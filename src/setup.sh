printLogo

isLinux

if [ "$USER_ID" != 0 ]; then
  printError "Initial setup must be run as sudo"
  exit 1
fi

authorized_key_exists=false

groupadd app

mkdir /srv/app
chgrp app /srv/app

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
