#!/usr/bin/env bash
function printLogo() {
  for i in $(seq 53 57); do printf "\e[48;5;%sm \e[0m" "$i"; done
  printf "\e[38;5;255;48;5;57m eva \e[0m"
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

  if [ $1 ]; then
    sed -i -r -e "s/^(\#?)(PasswordAuthentication)([[:space:]]+).+$/\2\3no/" /etc/ssh/sshd_config
  fi

  service sshd restart
  printProcessSuccess

  printProcess "Enable UFW"
  ufw allow $ssh >/dev/null 2>&1
  ufw --force enable >/dev/null 2>&1
  printProcessSuccess
}
function tuneUser() {
  if [ -z "$user" ]; then
    read -p "User name: " user

    if [ -z "$user" ]; then
      echo "User name required"
      exit 3
    fi
  fi

  egrep "^$user" /etc/passwd >/dev/null

  if [ $? -eq 0 ]; then
    echo "User $user already exists"
    exit 4
  fi

  password=$(openssl rand -base64 12)
  encryptedPassword=$(perl -e 'print crypt($ARGV[0], "password")' "$password")

  printProcess "Create new sudo user $user"
  useradd -d "/home/$user" -m -p "$encryptedPassword" -s "/bin/bash" $user
  usermod -aG sudo $user
  printProcessSuccess

  printf "password \e[38;5;255;48;5;237m %s \e[0m\n" "$password"

  if [ -f /root/.ssh/authorized_keys ]; then
    authorized_keys=true
    printProcess "Copy root's authorized keys to new user "

    mkdir -p /home/$user/.ssh
    cp /root/.ssh/authorized_keys /home/$user/.ssh/authorized_keys
    chown -R $user:$user /home/$user/.ssh

    printProcessSuccess
  fi
}
printLogo

isLinux

if [ "$USER_ID" != 0 ]; then
  printError "Initial setup must be run as sudo"
  exit 1
fi

authorized_key_exists=false

tuneUser

if [ $authorized_key_exists ]; then
  tuneSSH true
else
  tuneSSH false
fi

su $user
