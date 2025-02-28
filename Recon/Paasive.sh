#!/bin/bash

# Configuration
DOMAIN="$1"
OUTPUT_DIR="passive_recon/$DOMAIN"
WORDLIST="/usr/share/wordlists/subdomains-top1million-5000.txt"
DNS_RESOLVER="1.1.1.1"
OTX_API_KEY="YOUR_OTX_API_KEY" # Optional
PASSIVETOTAL_API_KEY="YOUR_PASSIVETOTAL_API_KEY" # Optional

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Step 1: Passive Reconnaissance
echo "[+] Step 1: Passive Reconnaissance"

# Subdomain Enumeration (Passive)
echo "[+] Subdomain Enumeration (Passive)..."

# Amass (Passive)
echo "[+] Amass (Passive)..."
amass enum -passive -d "$DOMAIN" -o "$OUTPUT_DIR/amass_passive.txt"

# crt.sh (Online)
echo "[+] crt.sh (Online)..."
curl -s "https://crt.sh/?q=%.${DOMAIN}&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u > "$OUTPUT_DIR/crtsh_subs.txt"

# Findomain
echo "[+] Findomain..."
findomain -t "$DOMAIN" -o "$OUTPUT_DIR/findomain_subs.txt"

# Assetfinder
echo "[+] Assetfinder..."
assetfinder --subs-only "$DOMAIN" >> "$OUTPUT_DIR/assetfinder_subs.txt"

# Sublist3r
echo "[+] Sublist3r..."
sublist3r -d "$DOMAIN" -o "$OUTPUT_DIR/sublist3r_subs.txt"

# DNSRecon
echo "[+] DNSRecon..."
dnsrecon -d "$DOMAIN" -D "$WORDLIST" -t brt -n "$DNS_RESOLVER" -o "$OUTPUT_DIR/dnsrecon_subs.txt"

# SecurityTrails (Online - Basic)
echo "[+] SecurityTrails (Online - Basic)..."
curl -s "https://api.securitytrails.com/v1/domain/${DOMAIN}/subdomains" | jq -r '.subdomains[] + ".${DOMAIN}"' | sort -u > "$OUTPUT_DIR/securitytrails_subs.txt"

# DNSDumpster (Online)
echo "[+] DNSDumpster (Online)..."
curl -s "https://dnsdumpster.com/static/map/${DOMAIN}.png" | grep -oE '[a-zA-Z0-9.-]+\.'"$DOMAIN" | sort -u > "$OUTPUT_DIR/dnsdumpster_subs.txt"

# VirusTotal (Online)
echo "[+] VirusTotal (Online)..."
curl -s "https://www.virustotal.com/ui/domains/${DOMAIN}/subdomains" | grep -oE '[a-zA-Z0-9.-]+\.'"$DOMAIN" | sort -u > "$OUTPUT_DIR/virustotal_subs.txt"

# AlienVault OTX (Online)
echo "[+] AlienVault OTX (Online)..."
if [[ -n "$OTX_API_KEY" ]]; then
  curl -s -H "X-OTX-API-KEY: $OTX_API_KEY" "https://otx.alienvault.com/api/v1/indicators/domain/$DOMAIN/passive_dns" | jq -r '.[].hostname' | sort -u >> "$OUTPUT_DIR/otx_subs.txt"
else
  echo "[!] OTX API key not set. Skipping OTX scan."
fi

# Bufferoverflown (Online)
echo "[+] Bufferoverflown (Online)..."
curl -s "https://dns.bufferoverflown.com/dns?q=.$DOMAIN" | grep -oE '[a-zA-Z0-9.-]+\.'"$DOMAIN" | sort -u > "$OUTPUT_DIR/bufferoverflown_subs.txt"

# URLScan.io (Online)
echo "[+] URLScan.io (Online)..."
curl -s "https://urlscan.io/api/v1/search/?q=domain:$DOMAIN" | jq -r '.results[].page.domain' | sort -u > "$OUTPUT_DIR/urlscan_subs.txt"

# PassiveTotal (Online)
echo "[+] PassiveTotal (Online)..."
if [[ -n "$PASSIVETOTAL_API_KEY" ]]; then
  curl -s -u "$PASSIVETOTAL_API_KEY:" "https://api.passivetotal.org/v2/dns/passive?query=$DOMAIN" | jq -r '.results[].resolve_hostname' | sort -u > "$OUTPUT_DIR/passivetotal_subs.txt"
else
  echo "[!] PassiveTotal API key not set. Skipping PassiveTotal scan."
fi

# Robtex (Online)
echo "[+] Robtex (Online)..."
curl -s "https://api.robtex.com/pdns/forward/$DOMAIN" | jq -r '.[].rrdata' | sort -u > "$OUTPUT_DIR/robtex_subs.txt"

# Google Dorking (Online)
echo "[+] Google Dorking (Online)..."
curl -s "https://www.google.com/search?q=site:*.${DOMAIN}&num=100" | grep -oE '[a-zA-Z0-9.-]+\.'"$DOMAIN" | sort -u > "$OUTPUT_DIR/google_dorking_subs.txt"

# Merge and Sort
echo "[+] Merging and Sorting Results..."
cat "$OUTPUT_DIR/amass_passive.txt" "$OUTPUT_DIR/crtsh_subs.txt" "$OUTPUT_DIR/findomain_subs.txt" "$OUTPUT_DIR/assetfinder_subs.txt" "$OUTPUT_DIR/sublist3r_subs.txt" "$OUTPUT_DIR/dnsrecon_subs.txt" "$OUTPUT_DIR/securitytrails_subs.txt" "$OUTPUT_DIR/dnsdumpster_subs.txt" "$OUTPUT_DIR/virustotal_subs.txt" "$OUTPUT_DIR/otx_subs.txt" "$OUTPUT_DIR/bufferoverflown_subs.txt" "$OUTPUT_DIR/urlscan_subs.txt" "$OUTPUT_DIR/passivetotal_subs.txt" "$OUTPUT_DIR/robtex_subs.txt" "$OUTPUT_DIR/google_dorking_subs.txt" | sort -u > "$OUTPUT_DIR/passive_subs.txt"

echo "[+] Passive Reconnaissance Complete. Results in $OUTPUT_DIR/passive_subs.txt"