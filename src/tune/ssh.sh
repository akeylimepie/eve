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
