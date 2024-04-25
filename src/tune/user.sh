function createUser(){
    printProcess "Create new user $1"

    password=$(openssl rand -base64 12)
    encryptedPassword=$(perl -e 'print crypt($ARGV[0], "password")' "$password")

    useradd -d "/home/$1" -m -p "$encryptedPassword" -s "/bin/bash" $1
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
    usermod -aG sudo $1

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
