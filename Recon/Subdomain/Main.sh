#!/bin/bash

###########################################################################
# Configuration
DOMAIN="$1"
domain="$1"
echo "Domain: $DOMAIN"
output="$HOME/Documents/$domain"
LOG_FILE="recon.log"
NUCLEI_TEMPLATES="/root/nuclei-templates"
SHODAN_API="$SHODAN_API_KEY"
CHAOS_API="$PDCP_API_KEY"
WORDLIST="/usr/share/wordlists/subdomain/n0kovo_subdomains_large.txt"
DNS_RESOLVER="/usr/share/wordlists/subdomain/resolvers.txt"
mkdir -p "$output" && touch "$LOG_FILE"
############################################################################


echo "[+] Starting Passive Recon on $DOMAIN"
# Passive Enumeration
read -p "Are you ready to start Passive Enumeration? (y/n):: " choice
if [ $choice == "y" ]; then
    echo "[+] Starting Active Enumeration on $DOMAIN"

    echo "******************************** Passive Enumeration ********************************"
    curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee "$output/crtsh.txt" 
    curl -s "https://otx.alienvault.com/api/v1/indicators/hostname/$domain/passive_dns" | jq -r '.passive_dns[]?.hostname' | grep -E "^[a-zA-Z0-9.-]+\.$domain$" | sort -u | tee "$output/alienvault.txt" 
    curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain&size=10000" | jq -r '.results[]?.page?.domain' | grep -E "^[a-zA-Z0-9.-]+\.$domain$" | sort -u | tee "$output/urlscan.txt" 
    curl -s "http://web.archive.org/cdx/search/cdx?url=*.${domain}/*&output=json&collapse=urlkey" | jq -r '.[1:][] | .[2]' | grep -Eo "([a-zA-Z0-9._-]+\.)?$domain" | sort -u | tee "$output/wayback.txt" 

else
    echo "[+] Exiting..."
    
fi  



# Active Enumeration 
read -p "Are you ready to start Active Enumeration? (y/n):: " choice
if [ $choice == "y" ]; then
    OUTPUT_DIR="$output/Actie"
    mkdir -p $OUTPUT_DIR
    echo "[+] Starting Active Enumeration on $DOMAIN"

    subfinder -d "$DOMAIN" -all -recursive -o "$OUTPUT_DIR/subfinder_subdomain.txt"
    wait
    assetfinder --subs-only "$DOMAIN" | tee "$OUTPUT_DIR/assetfinder_subdomain.txt"
    wait
    shodan search domain:"$DOMAIN" | jq -r '.matches[]?.hostnames[]' | sort -u | tee "$OUTPUT_DIR/shodan_subdomain.txt"
    shodanx subdomain -d "$DOMAIN" -ra -o "$OUTPUT_DIR/shodanx_subdomain.txt"
    findomain -t "$DOMAIN" -v -u $OUTPUT_DIR/findomain_subdomain.txt
    wait
    anubis -t "$DOMAIN" -o "$OUTPUT_DIR/anubis_subs.txt" 
    chaos -d "$DOMAIN" -k "$CHAOS_KEY" -o "$OUTPUT_DIR/chaos_subs.txt" 
    sublist3r -d "$DOMAIN" -o "$OUTPUT_DIR/sublist3r_subs.txt" 

    wait
    knockpy -d "$DOMAIN" --recon --save report --json
    grep '"domain"' "report/{domain}"*.json | awk -F'"' '{print $4}' | tee "$OUTPUT_DIR/knockpy_subdomain.txt"
    wait
    echo "******************************** Bruteforce Enumeration ********************************"
    subrute -t "$DOMAIN" -r $DNS_RESOLVER -v -o "$OUTPUT_DIR/subbrute_subdomain.txt"
    wait
    gobuster dns -d "$DOMAIN" -w "$WORDLIST" -o $OUTPUT_DIR/gobuster_subdomain.txt
    wait
    dnsrecon -d "$DOMAIN" -D "$WORDLIST" -t brt -n "$DNS_RESOLVER" -o "$OUTPUT_DIR/dnsrecon_subs.txt"
    
    amass enum -norecursive  -d "$DOMAIN" -o $OUTPUT_DIR/amass_subdomain.txt
    
else
    echo "[+] Exiting..."
    exit 0
fi  


