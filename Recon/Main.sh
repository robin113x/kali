#!/bin/bash

# Configuration
DOMAIN="$1"
echo "Domain: $DOMAIN"
OUTPUT_DIR="results/$DOMAIN"
LOG_FILE="recon.log"
NUCLEI_TEMPLATES="/root/nuclei-templates
SHODAN_API=$SHODAN_API_KEY
CHAOS_API=$PDCP_API_KEY
WORDLIST="/usr/share/wordlist/n0kovo_subdomains/n0kovo_subdomains_large.txt"
DNS_RESOLVER="/usr/share/wordlist/resolvers.txt"


# Ensure output directory exists
mkdir -p "$OUTPUT_DIR" && touch "$LOG_FILE"
cd $OUTPUT_DIR
pwd

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "[+] Starting Advanced Recon on $DOMAIN"
echo "[+] Starting Passive Recon on $DOMAIN"

# Passive Enumeration
read -p "Are you ready to start Passive Enumeration? (y/n): " choice
if [ $choice == "y" ]; then
    echo "[+] Starting Active Enumeration on $DOMAIN"
    chmod +x Subdomain/PassiveRecon.sh
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
    chmod +x Subdomain/ActiveRecon.sh
    bash Subdomain/ActiveRecon.sh $DOMAIN
    exit 0
else
    echo "[+] Exiting..."
    exit 0
fi  


