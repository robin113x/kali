# Passive subdomain enumeration
passive_enum() {
    echo "******************************** Passive Enumeration ********************************"
    sudo curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee "$output/crtsh.txt"
    curl -s "https://otx.alienvault.com/api/v1/indicators/hostname/$domain/passive_dns" | jq -r '.passive_dns[]?.hostname' | sort -u | tee "$output/alienvault.txt"
    curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain&size=10000" | jq -r '.results[]?.page?.domain' | sort -u | tee "$output/urlscan.txt"
    curl -s "http://web.archive.org/cdx/search/cdx?url=*.${domain}/*&output=json&collapse=urlkey" | jq -r '.[1:][] | .[2]' | sort -u | tee "$output/wayback.txt"wait
}

passive_enum
wait
echo "******************************** Passive Enumeration Completed ********************************"
echo "******************************** Subdomain Enumeration Completed ********************************"
    