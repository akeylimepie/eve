#!/usr/bin/env bash
function printLogo() {
  for i in $(seq 53 57); do printf "\e[48;5;%sm \e[0m" "$i"; done
  printf "\e[38;5;255;48;5;57m eve \e[0m"
  for i in $(seq 57 -1 53); do printf "\e[48;5;%sm \e[0m" "$i"; done
  echo
}

function printProcess() {
  printf "%s ∴" "$1"
}

function printProcessSuccess() {
  printf "\b\e[38;5;2m✔\e[0m\n"
}

function printProcessFail() {
  printf "\b\e[38;5;1m✘︎\e[0m\n"
}

function printSuccess() {
  printf "\e[38;5;2m%s\e[0m\n" "$1"
}

function printWarning() {
  printf "\e[38;5;3m%s\e[0m\n" "$1"
}

function printError() {
  printf "\e[38;5;1m%s\e[0m\n" "$1"
}
OS=$(uname)
USER_ID=$(id -u)

function isLinux() {
  if [ "$OS" != 'Linux' ]; then
    printError "It's only for Linux, sorry"
    exit 1
  fi
}

function binExists() {
  if command -v "$1" &>/dev/null; then
    echo 1
  else
    echo 0
  fi
}
function tuneSSH() {
  if [ -z "$ssh" ]; then
    read -p "SSH port [22]: " ssh

    if [ -z "$ssh" ]; then
      ssh=22
    fi
  fi

  printProcess "Update SSH"
  sed -i -r -e "s/^(\#?)(Port)([[:space:]]+).+$/\2\3$ssh/" /etc/ssh/sshd_config
  sed -i -r -e "s/^(\#?)(PermitRootLogin)([[:space:]]+).+$/\2\3no/" /etc/ssh/sshd_config

  sed -i -r -e "s/^(ListenStream=).+$/\1$ssh/" /lib/systemd/system/ssh.socket

  if [ $1 ]; then
    sed -i -r -e "s/^(\#?)(PasswordAuthentication)([[:space:]]+).+$/\2\3no/" /etc/ssh/sshd_config
  fi

  service sshd restart &> /dev/null
  service systemctl daemon-reload &> /dev/null
  service systemctl restart ssh &> /dev/null
  printProcessSuccess

  printProcess "Enable UFW"
  ufw allow $ssh >/dev/null 2>&1
  ufw --force enable >/dev/null 2>&1
  printProcessSuccess
}
function createUser(){
    printProcess "Create new user $1"

    password=$(openssl rand -base64 12)
    encryptedPassword=$(perl -e 'print crypt($ARGV[0], "password")' "$password")

    useradd -d "/home/$1" -m -p "$encryptedPassword" -s "/bin/bash" $1
    usermod -aG sudo $1
    usermod -aG docker $1
    usermod -aG app $1

    printProcessSuccess
    printf "password \e[38;5;255;48;5;237m %s \e[0m\n" "$password"
}

function addUser() {
  egrep "^$1" /etc/passwd >/dev/null

  if [ $? -eq 0 ]; then
    printProcess "User $1 already exists"
    printProcessFail
  else
    createUser $1

    if [ -f /root/.ssh/authorized_keys ]; then
      authorized_keys=true
      printProcess "Copy root's authorized keys to new user "

      mkdir -p /home/$1/.ssh
      cp /root/.ssh/authorized_keys /home/$1/.ssh/authorized_keys
      chown -R $1:$1 /home/$1/.ssh

      printProcessSuccess
    fi
  fi
}

function addDeployUser() {
  egrep "^$1" /etc/passwd >/dev/null

  if [ $? -eq 0 ]; then
    printProcess "User $1 already exists"
    printProcessFail
  else
    createUser $1

    mkdir -p /home/$1/.ssh
    touch /home/$1/.ssh/authorized_keys
    chown -R $1:$1 /home/$1/.ssh
  fi
}
printLogo

isLinux

if [ "$USER_ID" != 0 ]; then
  printError "Initial setup must be run as sudo"
  exit 1
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
