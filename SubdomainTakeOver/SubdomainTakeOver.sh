# Subdomain Takeover Testing
takeover_testing() {
    echo "******************************** Subdomain Takeover Testing ********************************"
    # subjack

    subzy r --targets "$domain_all_subdomains.txt"  | tee subdomain_takeOver.txt

    
        subjack -w "$domain_all_subdomains.txt" -t 100 -timeout 30 -ssl -v > subjack_takeover.txt
    
        SubOver -l "$domain_all_subdomains.txt" -o SubOver_takeover.txt
    fi
    # autoSubTakeover
    if command -v autoSubTakeover &> /dev/null; then
        autoSubTakeover -l "$domain_all_subdomains.txt" -o autoSubTakeover_takeover.txt
    fi
    # tko-subs
    if command -v tko-subs &> /dev/null; then
        tko-subs -l "$domain_all_subdomains.txt" -o tko_subs_takeover.txt
    fi
    # takeover
    if command -v takeover &> /dev/null; then
      takeover -l "$domain_all_subdomains.txt" -o takeover_tool.txt
    fi
    #dnsReaper
    if command -v dnsReaper &> /dev/null; then
        dnsReaper -l "$domain_all_subdomains.txt" -o dnsReaper_takeover.txt
    fi
    # cnames
    if command -v cnames &> /dev/null; then
        cat "$domain_all_subdomains.txt" | cnames > cnames_output.txt
    fi
    #second-order
    if command -v second-order &> /dev/null; then
        second-order -l "$domain_all_subdomains.txt" -o second_order_takeover.txt
    fi
    #subHijack
    if command -v subHijack &> /dev/null; then
        subHijack -l "$domain_all_subdomains.txt" -o subHijack_takeover.txt
    fi
    #NSBrute
    if command -v NSBrute &> /dev/null; then
        NSBrute -d "$domain" -l "$domain_all_subdomains.txt" -o NSBrute_takeover.txt
    fi
    #can-i-take-over-xyz (this is not a tool but an online resource, so we can't automate it)
    echo "[INFO] Manual check of 'can-i-take-over-xyz' resource is recommended."

    echo "[INFO] Subdomain Takeover testing completed. Results in *_takeover.txt files."
}