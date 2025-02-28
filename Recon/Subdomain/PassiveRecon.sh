# Passive subdomain enumeration
passive_enum() {
    echo "******************************** Passive Enumeration ********************************"
echo "******************************** Passive Enumeration ********************************"
    curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee "crtsh_passive.txt"
    curl -s "https://otx.alienvault.com/api/v1/indicators/hostname/$domain/passive_dns" | jq -r '.passive_dns[]?.hostname' | sort -u | tee "alienvault_passive.txt"
    curl -s "https://api.hackertarget.com/hostsearch/?q=$domain" | cut -d',' -f1 | sort -u | tee "hackertarget_passive.txt"
    curl -s "https://api.threatcrowd.org/searchApi/v2/domain/report/?domain=$domain" | jq -r '.subdomains[]' | sort -u | tee "threatcrowd_passive.txt"
    curl -s "https://riddler.io/search/exportcsv?q=pld:$domain" | grep -oE "[a-zA-Z0-9._-]+\.$domain" | sort -u | tee "riddler_passive.txt"
    curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain&size=10000" | jq -r '.results[]?.page?.domain' | sort -u | tee "urlscan_passive.txt"
}

passive_enum