#!/bin/bash

# Configuration
DOMAIN="$1"
echo "Domain: $DOMAIN"
OUTPUT_DIR="results/$DOMAIN"
LOG_FILE="recon.log"
NUCLEI_TEMPLATES="/root/nuclei-templates
SHODAN_API=$SHODAN_API_KEY
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

# Passive Enumeration
read -p "Are you ready to start Passive Enumeration? (y/n): " choice
if [ $choice == "y" ]; then
    echo "[+] Starting Active Enumeration on $DOMAIN"
    bash Subdomain/PassiveRecon.sh $DOMAIN
    exit 0
else
    echo "[+] Exiting..."
    exit 0
fi  

# Active Enumeration
read -p "Are you ready to start Active Enumeration? (y/n): " choice
if [ $choice == "y" ]; then
    echo "[+] Starting Active Enumeration on $DOMAIN"
    bash Subdomain/ActiveRecon.sh $DOMAIN
    exit 0
else
    echo "[+] Exiting..."
    exit 0
fi  


