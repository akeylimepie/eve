function tuneSSH() {
  if [ -z "$ssh" ]; then
    read -p "SSH port [22]: " ssh

    if [ -z "$ssh" ]; then
      ssh=22
    fi
  fi

  printProcess "Update SSH"
  touch /etc/ssh/sshd_config.d/99-eve.conf

  echo "Port $ssh" >> /etc/ssh/sshd_config.d/99-eve.conf
  echo "PermitRootLogin no" >> /etc/ssh/sshd_config.d/99-eve.conf

  if [ $1 ]; then
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config.d/99-eve.conf
  fi

  sed -i -r -e "s/^(ListenStream=).+$/\1$ssh/" /lib/systemd/system/ssh.socket

  service sshd restart &> /dev/null
  service systemctl daemon-reload &> /dev/null
  service systemctl restart ssh &> /dev/null
  printProcessSuccess

  printProcess "Enable UFW"
  ufw allow $ssh >/dev/null 2>&1
  ufw --force enable >/dev/null 2>&1
  printProcessSuccess
}
