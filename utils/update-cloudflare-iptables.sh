#!/bin/bash

IPTABLES_DIR="/root/.eve/iptables"
RULES_V4="$IPTABLES_DIR/rules.v4"
RULES_V6="$IPTABLES_DIR/rules.v6"

TMP_IPV4="/tmp/cloudflare_ips_v4.txt"
TMP_IPV6="/tmp/cloudflare_ips_v6.txt"

curl -s -o "$TMP_IPV4" -w "%{http_code}" "https://www.cloudflare.com/ips-v4" | grep -q "200" || exit 1
curl -s -o "$TMP_IPV6" -w "%{http_code}" "https://www.cloudflare.com/ips-v6" | grep -q "200" || exit 1

iptables -F DOCKER-USER
ip6tables -F DOCKER-USER

while read -r ip; do
  [[ -n "$ip" ]] && iptables -I DOCKER-USER -p tcp -i eth0 -m multiport --dports 80,443 -s "$ip" -j RETURN
done < "$TMP_IPV4"

while read -r ip; do
  [[ -n "$ip" ]] && ip6tables -I DOCKER-USER -p tcp -i eth0 -m multiport --dports 80,443 -s "$ip" -j RETURN
done < "$TMP_IPV6"

rm -f "$TMP_IPV4" "$TMP_IPV6"

iptables -I DOCKER-USER -i docker0 -j RETURN
ip6tables -I DOCKER-USER -i docker0 -j RETURN

iptables -A DOCKER-USER -p tcp -i eth0 -m multiport --dports 80,443 -j DROP
ip6tables -A DOCKER-USER -p tcp -i eth0 -m multiport --dports 80,443 -j DROP

{
    echo "*filter"
    echo "-F DOCKER-USER"
    iptables-save | grep -E '^-A DOCKER-USER'
    echo "COMMIT"
} > "$RULES_V4"

{
    echo "*filter"
    echo "-F DOCKER-USER"
    ip6tables-save | grep -E '^-A DOCKER-USER'
    echo "COMMIT"
} > "$RULES_V6"
