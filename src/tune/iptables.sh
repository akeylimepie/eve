function tuneIptabes() {
  IPTABLES_DIR="/root/.eve/iptables"
  UPDATE_SCRIPT="$IPTABLES_DIR/update.sh"

  RULES_V4="$IPTABLES_DIR/rules.v4"
  RULES_V6="$IPTABLES_DIR/rules.v6"

  mkdir -p "$IPTABLES_DIR"

  curl -s https://raw.githubusercontent.com/akeylimepie/eve/master/utils/update-cloudflare-iptables.sh > "$UPDATE_SCRIPT"

  chmod +x "$UPDATE_SCRIPT"

  cat <<EOL > "/etc/systemd/system/restore-docker-iptables-rules.service"
[Unit]
Description=Restore iptables rules
After=docker.service network.target
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore -n $RULES_V4
ExecStart=/sbin/ip6tables-restore -n $RULES_V6

[Install]
WantedBy=multi-user.target
EOL

  cat <<EOL > "/etc/systemd/system/update-cloudflare-iptables-rules.service"
[Unit]
Description=Update Cloudflare IP rules

[Service]
Type=oneshot
ExecStart=$UPDATE_SCRIPT
EOL

  cat <<EOL > "/etc/systemd/system/update-cloudflare-iptables-rules.timer"
[Unit]
Description=Update Cloudflare IP rules daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOL

  systemctl daemon-reload
  systemctl enable restore-docker-iptables-rules.service
  systemctl enable --now update-cloudflare-iptables-rules.timer
  systemctl start update-cloudflare-iptables-rules.service
}
