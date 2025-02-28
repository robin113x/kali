# Active enumeration
active_enum() {
    echo "******************************** Active Enumeration ********************************"
    subfinder -d "$DOMAIN" -all -recursive -o "$OUTPUT_DIR/subfinder_subdomain.txt"
    assetfinder --subs-only "$DOMAIN" | tee "$OUTPUT_DIR/assetfinder_subdomain.txt"
    shodan search domain:"$DOMAIN" | jq -r '.matches[]?.hostnames[]' | sort -u | tee "$OUTPUT_DIR/shodan_subdomain.txt"
    shodanx subdomain -d "$DOMAIN" -ra -o "$OUTPUT_DIR/shodanx_subdomain.txt"
    findomain -t "$DOMAIN" -v -o $OUTPUT_DIR/findomain_subdomain.txt
    amass enum -norecursive  -d "$DOMAIN" -o $OUTPUT_DIR/amass_subdomain.txt
    anubis -d "$DOMAIN" -o "$OUTPUT_DIR/anubis_subs.txt" 
    chaos -d "$DOMAIN" -k "$CHAOS_KEY" -o "$OUTPUT_DIR/chaos_subs.txt" 
    sublist3r -d "$DOMAIN" -o "$OUTPUT_DIR/sublist3r_subs.txt" 

}

# Brute-force enumeration
bruteforce_enum() {
    echo "******************************** Bruteforce Enumeration ********************************"
    subrute -d "$DOMAIN" | tee "$OUTPUT_DIR/subbrute_subdomain.txt"
    gobuster dns -d "$DOMAIN" -w "$WORDLIST" -o $OUTPUT_DIR/gobuster_subdomain.txt
    dnsrecon -d "$DOMAIN" -D "$WORDLIST" -t brt -n "$DNS_RESOLVER" -o "$OUTPUT_DIR/dnsrecon_subs.txt"
   
}

knockpy_enum() {
    echo "******************************** Running Knockpy ********************************"
    knockpy -d "$DOMAIN" --recon --save report --json
    grep '"domain"' "report/{domain}"*.json | awk -F'"' '{print $4}' | tee "knockpy_subdomain.txt"

}

active_enum
knockpy_enum
bruteforce_enum