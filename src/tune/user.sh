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
