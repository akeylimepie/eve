function tuneSSH() {
  if [ -z "$ssh" ]; then
    read -p "SSH port [22]: " ssh

    if [ -z "$ssh" ]; then
      ssh=22
    fi
  fi

  printProcess "Update SSH"

  cat > /etc/ssh/sshd_config.d/90-eve.conf <<EOF
Port $ssh
PermitRootLogin no
EOF

  if [ $1 ]; then
  cat >> /etc/ssh/sshd_config.d/90-eve.conf <<EOF
PasswordAuthentication no
EOF
  fi

  systemctl daemon-reload
  systemctl restart ssh
  systemctl restart ssh.socket
  printProcessSuccess

  printProcess "Enable UFW"
  ufw allow $ssh >/dev/null 2>&1
  ufw --force enable >/dev/null 2>&1
  printProcessSuccess
}
