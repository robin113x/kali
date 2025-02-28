#!/bin/bash

# Configuration
DOMAIN="$1"
echo "Domain: $DOMAIN"
OUTPUT_DIR="results/$DOMAIN"
LOG_FILE="recon.log"
NUCLEI_TEMPLATES="/root/nuclei-templates
SHODAN_API="22905caf0b00f7f97261d498140046a07925b8c22f8d21b12fcad6b1b8357105"
CHAOS_API="a11c9305-a0b8-42e7-b6ba-f92349513c66"
CENSYS_API
WORDLIST="/usr/share/wordlist/n0kovo_subdomains/n0kovo_subdomains_large.txt"
DNS_RESOLVER="/usr/share/wordlist/resolvers.txt"


# Ensure output directory exists
mkdir -p "$OUTPUT_DIR" && touch "$LOG_FILE"
cd $OUTPUT_DIR

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "[+] Starting Advanced Recon on $DOMAIN"
echo "[+] Starting Passive Recon on $DOMAIN"

# Passive enumeration
bash Subdomain/PassiveRecon.sh $DOMAIN

read -p "Are you ready to start Active Enumeration? (y/n): " choice
if [ $choice == "n" ]; then
    exit 1
fi  

# Active enumeration
bash Subdomain/ActiveRecon.sh $DOMAIN
