passive_enum() {
    echo "******************************** Passive Enumeration ********************************"

    # Create output directory if not exists
    mkdir -p "$output"

    # Function to check if response is valid JSON
    is_valid_json() {
        echo "$1" | jq empty > /dev/null 2>&1
        return $?
    }

    # crt.sh (Certificate Transparency Logs)
    crt_response=$(curl -s "https://crt.sh/?q=%.$domain&output=json")
    if is_valid_json "$crt_response"; then
        echo "$crt_response" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee "$output/crtsh.txt"
    else
        echo "[!] crt.sh API response is not valid JSON" | tee -a "$output/errors.log"
    fi

    # AlienVault
    av_response=$(curl -s "https://otx.alienvault.com/api/v1/indicators/hostname/$domain/passive_dns")
    if is_valid_json "$av_response"; then
        echo "$av_response" | jq -r '.passive_dns[]?.hostname' | sort -u | tee "$output/alienvault.txt"
    else
        echo "[!] AlienVault API response is not valid JSON" | tee -a "$output/errors.log"
    fi

    # urlscan.io
    urlscan_response=$(curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain&size=10000")
    if is_valid_json "$urlscan_response"; then
        echo "$urlscan_response" | jq -r '.results[]?.page?.domain' | sort -u | tee "$output/urlscan.txt"
    else
        echo "[!] urlscan.io API response is not valid JSON" | tee -a "$output/errors.log"
    fi

    # Wayback Machine
    wayback_response=$(curl -s "http://web.archive.org/cdx/search/cdx?url=*.${domain}/*&output=json&collapse=urlkey")
    if is_valid_json "$wayback_response"; then
        echo "$wayback_response" | jq -r '.[1:][] | .[2]' | sort -u | tee "$output/wayback.txt"
    else
        echo "[!] Wayback Machine API response is not valid JSON" | tee -a "$output/errors.log"
    fi

    echo "******************************** Passive Enumeration Completed ********************************"
}
