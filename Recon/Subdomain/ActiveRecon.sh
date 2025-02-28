# Active enumeration
active_enum() {
    echo "******************************** Active Enumeration ********************************"
    subfinder -d "$domain" -all -recursive -o "subfinder_subdomain.txt"
    assetfinder --subs-only "$domain" | tee "assetfinder_subdomain.txt"
    shodan search domain:"$domain" | jq -r '.matches[]?.hostnames[]' | sort -u | tee "shodan_subdomain.txt"
    shodanx subdomain -d "$domain" -ra -o "shodanx_subdomain.txt"
    findomain -t "$domain" -v -o findomain_subdomain.txt
    amass enum -norecursive  -d "$domain" -o amass_subdomain.txt
    anubis -d "$DOMAIN" -o "anubis_subs.txt" 
    chaos -d "$DOMAIN" -k "$CHAOS_KEY" -o "chaos_subs.txt" 
    sublist3r -d "$DOMAIN" -o "sublist3r_subs.txt" 
    dnsrecon -d "$DOMAIN" -D "$WORDLIST" -t brt -n "$DNS_RESOLVER" -o "dnsrecon_subs.txt"

}

# Brute-force enumeration
bruteforce_enum() {
    echo "******************************** Bruteforce Enumeration ********************************"
    subrute -d "$domain" | tee "subbrute_subdomain.txt"
    gobuster dns -d "$domain" -w /usr/share/wordlist/n0kovo_subdomains/n0kovo_subdomains_large.txt -o gobuster_subdomain.txt
    

}