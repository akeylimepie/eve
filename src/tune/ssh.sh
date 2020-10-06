function tuneSSH() {
  if [ -z "$ssh_port" ]; then
    read -p "SSH port [22]: " ssh_port

    if [ -z "$ssh_port" ]; then
      ssh_port=22
    fi
  fi

  printProcess "Update SSH"
  sed -i -r -e "s/^(\#?)(Port)([[:space:]]+).+$/\2\3$ssh_port/" /etc/ssh/sshd_config
  sed -i -r -e "s/^(\#?)(PermitRootLogin)([[:space:]]+).+$/\2\3no/" /etc/ssh/sshd_config

  if [ $1 ]; then
    sed -i -r -e "s/^(\#?)(PasswordAuthentication)([[:space:]]+).+$/\2\3no/" /etc/ssh/sshd_config
  fi

  service sshd restart
  printProcessSuccess

  printProcess "Enable UFW"
  ufw allow $ssh_port > /dev/null 2>&1
  ufw --force enable > /dev/null 2>&1
  printProcessSuccess
}
