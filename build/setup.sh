#!/usr/bin/env bash
function printLogo() {
  for i in $(seq 53 57); do printf "\e[48;5;%sm \e[0m" "$i"; done
  printf "\e[38;5;256;48;5;57m eva \e[0m"
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
function tuneSSH() {
  if [ -z "$ssh_port" ]; then
    read -p "SSH port [22]: " ssh_port

    if [ -z "$ssh_port" ]; then
      ssh_port=22
    fi
  fi

  printProcess "Update SSH config, restart service"
  sed -i -r -e "s/^(\#?)(Port)([[:space:]]+).+$/\2\3$ssh_port/" /etc/ssh/sshd_config
  sed -i -r -e "s/^(\#?)(PermitRootLogin)([[:space:]]+).+$/\2\3no/" /etc/ssh/sshd_config

  if [ $1 ]; then
    sed -i -r -e "s/^(\#?)(PasswordAuthentication)([[:space:]]+).+$/\2\3no/" /etc/ssh/sshd_config
  fi

  service sshd restart
  printProcessSuccess

  printProcess "Update UFW"
  printProcessSuccess
  ufw allow $ssh_port
  ufw --force enable
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
  encryptedPassword=$(perl -e 'print crypt($ARGV[0], "password")' $password)

  printProcess "Create new sudo user"
  useradd -d "/home/$user" -m -p "$encryptedPassword" -s "/bin/bash" $user
  usermod -aG sudo $user
  printProcessSuccess

  printSuccess "$user: $encryptedPassword"

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