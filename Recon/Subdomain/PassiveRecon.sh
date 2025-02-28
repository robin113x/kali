# Passive subdomain enumeration
passive_enum() {
    echo "******************************** Passive Enumeration ********************************"

    curl -s "https://dns.bufferover.run/dns?q=.$DOMAIN" | jq -r '.FDNS_A[]' | awk -F ',' '{print $2}' > "bufferover_subs.txt" 
    curl -s "https://publicwww.com/websites/%22$DOMAIN%22/?export=csv" | awk -F '","' '{print $2}' > "publicwww_subs.txt" 
    curl -s "http://web.archive.org/cdx/search/cdx?url=*.${DOMAIN}/*&output=json&collapse=urlkey" | jq -r '.[1:][] | .[2]' | sort -u | tee "wayback_passive_subs.txt"
    curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee "crtsh_passive.txt"
    curl -s "https://otx.alienvault.com/api/v1/indicators/hostname/$domain/passive_dns" | jq -r '.passive_dns[]?.hostname' | sort -u | tee "alienvault_passive.txt"
    curl -s "https://api.threatminer.org/v2/domain.php?q=$domain&rt=5" | jq -r '.data[].subdomains' | grep -oE "[a-zA-Z0-9._-]+\.$domain" | sort -u | tee "threatminer_passive.txt"
    curl -s "https://api.threatbook.cn/v3/domain/subdomain?domain=$domain" | jq -r '.data[]' | sort -u | tee "threatbook_passive.txt"
    curl -s "https://api.hackertarget.com/hostsearch/?q=$domain" | cut -d',' -f1 | sort -u | tee "hackertarget_passive.txt"
    curl -s "https://api.threatcrowd.org/searchApi/v2/domain/report/?domain=$domain" | jq -r '.subdomains[]' | sort -u | tee "threatcrowd_passive.txt"
    curl -s "https://riddler.io/search/exportcsv?q=pld:$domain" | grep -oE "[a-zA-Z0-9._-]+\.$domain" | sort -u | tee "riddler_passive.txt"
    curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain&size=10000" | jq -r '.results[]?.page?.domain' | sort -u | tee "urlscan_passive.txt"
    curl -s "https://rapiddns.io/subdomain/$domain?full=1#result" | grep "<td><a" | cut -d '"' -f 2 | grep http | cut -d '/' -f3 | sed 's/#results//g' | sort -u | tee "rapiddns_passive.txt"
    curl -s "https://www.virustotal.com/ui/domains/$domain/subdomains?limit=40" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | sort -u | tee "virustotal_passive.txt"
    curl -s "https://securitytrails.com/list/apex_domain/$domain" | grep -Po "((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+" | grep ".$domain" | sort -u | tee "securitytrails_passive.txt"
    curl --silent https://sonar.omnisint.io/subdomains/$domain | grep -oE "[a-zA-Z0-9._-]+\.$domain" | sort -u | tee "sonar_passive.txt"
    curl --silent -X POST https://synapsint.com/report.php -d "name=https%3A%2F%2F$domain" | grep -oE "[a-zA-Z0-9._-]+\.$domain" | sort -u | tee "synapsint_passive.txt"
    curl -s "https://api.sublist3r.com/search.php?domain=$domain" | jq -r '.subdomains[]' | sort -u | tee "sublist3r_passive.txt"
    curl -s "https://api.certspotter.com/v1/issuances?domain=$domain&include_subdomains=true&expand=dns_names" | jq -r '.[].dns_names[]' | sort -u | tee "certspotter_passive.txt"
    
}
