# 🧭 getcidr.sh — IP → CIDR & WHOIS Recon Tool

`getcidr.sh` is a lightweight yet powerful **IP intelligence and allocation discovery** tool. It retrieves **CIDR range**, **ASN**, **netname**, and **abuse contact** info using both **RDAP** and **WHOIS** data sources.

---

## 🚀 Features

* 🔍 Fetches **parent CIDR allocation** via RDAP (RIPE database).
* 🌍 Pulls **routed prefix**, **ASN**, **netname**, and **description** via WHOIS.
* 📧 Extracts **abuse contact emails** automatically.
* 🧱 Displays a **compact WHOIS snippet** (key network fields only).
* ⚙️ Works on any Linux/macOS terminal with `curl`, `jq`, and `whois`.

---

## 🧰 Requirements

Ensure the following tools are installed:

```bash
sudo apt install jq whois curl -y
```

---

## 🧩 Usage

```bash
./getcidr.sh <IP>
```

**Example:**

```bash
./getcidr.sh 85.185.8.84
```

---

## 🧾 Example Output

```
=== RDAP / Registry allocation ===
Parent allocation: 85.185.8.0/22

=== RIPE WHOIS / Routed prefix & details ===
Routed prefix: 85.185.8.0/22
ASN: AS58224
Netname: TCI-TELECOM
Description: Telecommunication Company of Iran (TCI)
Abuse contact: abuse@tci.ir

=== Full WHOIS snippet ===
inetnum: 85.185.8.0 - 85.185.11.255
netname: TCI-TELECOM
route: 85.185.8.0/22
descr: Telecommunication Company of Iran
abuse-mailbox: abuse@tci.ir
```

---

## 🧠 How It Works

1. **RDAP Query** → Fetches parent CIDR using RIPE’s RDAP API.
2. **WHOIS Query** → Pulls deeper registration info like ASN, route, and contacts.
3. **Regex + JQ Parsing** → Extracts key fields cleanly for human-readable output.

---

## ⚡ Tips

* Combine with your other tools for a full IP reconnaissance chain:

  ```bash
  ./GetIPAsn.sh <domain> | ./getcidr.sh
  ```
* Use `grep` or `jq` to extract CIDRs or ASNs for automation pipelines.

---

## 🧑‍💻 Author

**Sephiroth (53Ph1R07h)**
Part of the **Custools/PT** toolkit — custom pentesting utilities.

---

## 🧱 License

MIT License — free to modify and redistribute with credit.

---

## Script (reference)

Below is the original `getcidr.sh` script this README documents. Keep it as the single-file source of truth in the repository.

```bash
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
```


