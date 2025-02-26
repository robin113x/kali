#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi


domain=$1
output="/home/robin/kali/BugBounty/$domain"
mkdir -p "$output"
cd "$output" || exit 1

log_file="$output/enumeration.log"
exec > >(tee -a "$log_file") 2>&1  

echo "Starting Subdomain Enumeration for $domain"
echo "Results will be saved in: $output"


handle_error() {
    echo "[ERROR] $1"
    exit 1
}

# Passive subdomain enumeration
passive_enum() {
    echo "******************************** Passive Enumeration ********************************"
    curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee "crtsh_passive.txt"
    curl -s "https://otx.alienvault.com/api/v1/indicators/hostname/$domain/passive_dns" | jq -r '.passive_dns[]?.hostname' | sort -u | tee "alienvault_passive.txt"
    curl -s "https://api.hackertarget.com/hostsearch/?q=$domain" | cut -d',' -f1 | sort -u | tee "hackertarget_passive.txt"
    curl -s "https://api.threatcrowd.org/searchApi/v2/domain/report/?domain=$domain" | jq -r '.subdomains[]' | sort -u | tee "threatcrowd_passive.txt"
    curl -s "https://riddler.io/search/exportcsv?q=pld:$domain" | grep -oE "[a-zA-Z0-9._-]+\.$domain" | sort -u | tee "riddler_passive.txt"
    curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain&size=10000" | jq -r '.results[]?.page?.domain' | sort -u | tee "urlscan_passive.txt"
}

# Active enumeration
active_enum() {
    echo "******************************** Active Enumeration ********************************"
    subfinder -d "$domain" -all -recursive -o "subfinder_subdomain.txt"
    assetfinder --subs-only "$domain" | tee "assetfinder_subdomain.txt"
    shodan search domain:"$domain" | jq -r '.matches[]?.hostnames[]' | sort -u | tee "shodan_subdomain.txt"
    shodanx subdomain -d "$domain" -ra -o "shodanx_subdomain.txt"
}

# Brute-force enumeration
bruteforce_enum() {
    echo "******************************** Bruteforce Enumeration ********************************"
    subrute -d "$domain" | tee "subbrute_subdomain.txt"
}

# combine results
combine_results() {
    echo "******************************** Combining All Results ********************************"
    cat *.txt | anew "$domain_all_subdomains.txt"
}




# Wayback Machine
wayback_urls() {
    echo "******************************** Fetching Wayback URLs ********************************"
    curl -s "http://web.archive.org/cdx/search/cdx?url=*.${domain}/*&output=json&collapse=urlkey" | jq -r '.[1:][] | .[2]' | sort -u | tee "wayback_passive.txt"
    waybackrobots -d "$domain" | tee "waybackrobots.txt"
    cat all_subdomains.txt | waybackurls | tee "urls_wayback.txt"
}

# subdomains of subdomains
subdomain_of_subdomain() {
    echo "******************************** Finding Subdomains of Subdomains ********************************"
    subfinder -dL all_subdomains.txt -o "subfinder_sub_of_sub.txt"
    assetfinder --subs-only -subs-only all_subdomains.txt | tee "assetfinder_sub_of_sub.txt"
}

# Knockpy
knockpy_enum() {
    echo "******************************** Running Knockpy ********************************"
    knockpy -d "$domain" --recon --save report --json
    grep '"domain"' "report/${domain}"*.json | awk -F'"' '{print $4}' | tee "knockpy_subdomain.txt"
}

# Calling all enumeration steps
#passive_enum
#active_enum
knockpy_enum
bruteforce_enum
combine_results
wayback_urls
subdomain_of_subdomain
combine_results  

echo "Subdomain enumeration completed. Check results in: $output"
echo "******************************** End of Enumeration ********************************"
