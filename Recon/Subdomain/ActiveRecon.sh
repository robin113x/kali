/usr/share/wordlist/n0kovo_subdomains/n0kovo_subdomains_large.txt

# Active enumeration
active_enum() {
    echo "******************************** Active Enumeration ********************************"
    subfinder -d "$DOMAIN" -all -recursive -o "subfinder_subdomain.txt"
    assetfinder --subs-only "$DOMAIN" | tee "assetfinder_subdomain.txt"
    shodan search domain:"$DOMAIN" | jq -r '.matches[]?.hostnames[]' | sort -u | tee "shodan_subdomain.txt"
    shodanx subdomain -d "$DOMAIN" -ra -o "shodanx_subdomain.txt"
    findomain -t "$DOMAIN" -v -o findomain_subdomain.txt
    amass enum -norecursive  -d "$DOMAIN" -o amass_subdomain.txt
    anubis -d "$DOMAIN" -o "anubis_subs.txt" 
    chaos -d "$DOMAIN" -k "$CHAOS_KEY" -o "chaos_subs.txt" 
    sublist3r -d "$DOMAIN" -o "sublist3r_subs.txt" 
    dnsrecon -d "$DOMAIN" -D "$WORDLIST" -t brt -n "$DNS_RESOLVER" -o "dnsrecon_subs.txt"

}

# Brute-force enumeration
bruteforce_enum() {
    echo "******************************** Bruteforce Enumeration ********************************"
    subrute -d "$DOMAIN" | tee "subbrute_subdomain.txt"
    gobuster dns -d "$DOMAIN" -w  -o gobuster_subdomain.txt
   
}

knockpy_enum() {
    echo "******************************** Running Knockpy ********************************"
    knockpy -d "$DOMAIN" --recon --save report --json
    grep '"domain"' "report/{domain}"*.json | awk -F'"' '{print $4}' | tee "knockpy_subdomain.txt"

}