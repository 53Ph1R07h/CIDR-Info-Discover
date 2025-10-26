#!/usr/bin/env bash
# Usage: getcidr.sh <IP>
# Example: ./getcidr.sh 85.185.8.84

if [ -z "$1" ]; then
    echo "Usage: $0 <IP>"
    exit 1
fi

IP="$1"

echo "=== RDAP / Registry allocation ==="
parent_cidr=$(curl -s "https://rdap.db.ripe.net/ip/$IP" \
    | jq -r '(.cidr0_cidrs[]? | "\(.v4prefix)/\(.length)") // 
              (.objects[]??.data[]? | select(.name=="inetnum") | .value)' 2>/dev/null)
echo "Parent allocation: $parent_cidr"

echo
echo "=== RIPE WHOIS / Routed prefix & details ==="
whois_output=$(whois -h whois.ripe.net "$IP")

# Routed CIDR
route=$(echo "$whois_output" | grep -i "^route:" | awk '{print $2}')
echo "Routed prefix: $route"

# ASN from mnt-routes or netname
asn=$(echo "$whois_output" | grep -i "^mnt-routes:" | awk '{print $2}')
echo "ASN: $asn"

# Netname
netname=$(echo "$whois_output" | grep -i "^netname:" | awk '{$1=""; print $0}' | xargs)
echo "Netname: $netname"

# Description
descr=$(echo "$whois_output" | grep -i "^descr:" | awk '{$1=""; print $0}' | xargs)
echo "Description: $descr"

# Abuse contact
abuse=$(echo "$whois_output" | grep -i "abuse" | grep -E -o "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
echo "Abuse contact: ${abuse:-Not listed}"

echo
echo "=== Full WHOIS snippet ==="
echo "$whois_output" | egrep -i "inetnum|netname|route|descr|abuse"
