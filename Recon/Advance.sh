#!/bin/bash

# Configuration
DOMAIN="$1"
OUTPUT_DIR="results/$DOMAIN"
LOG_FILE="recon.log"
NUCLEI_TEMPLATES="/root/nuclei-templates"
SHODAN_API_KEY="YOUR_SHODAN_API_KEY"
CHAOS_KEY="YOUR_CHAOS_API_KEY"
CENSYS_API_KEY="YOUR_CENSYS_API_KEY"
WORDLIST="/usr/share/wordlists/subDOMAINs-top1million-5000.txt"
DNS_RESOLVER="1.1.1.1"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR" && touch "$LOG_FILE"
cd $OUTPUT_DIR

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "[+] Starting Advanced Recon on $DOMAIN"

### **Step 1: Passive Reconnaissance (Extended)**
log "[+] Step 1: Passive Reconnaissance (Extended)"

(
    amass enum -passive -d "$DOMAIN" -o "amass_passive.txt" 
    crt.sh "$DOMAIN" | grep "$DOMAIN" | awk '{print $4}' | sort -u > "crtsh_subs.txt" 
    findomain -t "$DOMAIN" -o "finDOMAIN_subs.txt" 
    assetfinder --subs-only "$DOMAIN" >> "assetfinder_subs.txt" 
    sublist3r -d "$DOMAIN" -o "sublist3r_subs.txt" 
    dnsrecon -d "$DOMAIN" -D "$WORDLIST" -t brt -n "$DNS_RESOLVER" -o "dnsrecon_subs.txt" 
    # Additional Passive Scanners
    subfinder -d "$DOMAIN" -o "subfinder_subs.txt" 
    anubis -d "$DOMAIN" -o "anubis_subs.txt" 
    chaos -d "$DOMAIN" -k "$CHAOS_KEY" -o "chaos_subs.txt" 
    
    curl -s "https://dns.bufferover.run/dns?q=.$DOMAIN" | jq -r '.FDNS_A[]' | awk -F ',' '{print $2}' > "bufferover_subs.txt" 
    curl -s "https://publicwww.com/websites/%22$DOMAIN%22/?export=csv" | awk -F '","' '{print $2}' > "publicwww_subs.txt" 
    curl -s "https://crt.sh/?q=%.$DOMAIN&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee "crtsh_passive_subs.txt"
    curl -s "https://otx.alienvault.com/api/v1/indicators/hostname/$DOMAIN/passive_dns" | jq -r '.passive_dns[]?.hostname' | sort -u | tee "alienvault_passive_subs.txt"
    curl -s "https://urlscan.io/api/v1/search/?q=DOMAIN:$DOMAIN&size=10000" | jq -r '.results[]?.page?.DOMAIN' | sort -u | tee "urlscan_passive_subs.txt"
    curl -s "http://web.archive.org/cdx/search/cdx?url=*.${DOMAIN}/*&output=json&collapse=urlkey" | jq -r '.[1:][] | .[2]' | sort -u | tee "wayback_passive_subs.txt"


    wait
)

cat *_subs.txt | anew "passive_subs.txt"

### **Step 2: Active Reconnaissance (Extended)**
log "[+] Step 2: Active Reconnaissance (Extended)"

(
    # Bruteforce SubDOMAINs
    gobuster dns -d "$DOMAIN" -w "$WORDLIST" -o "gobuster_subs.txt" &
    altDNS -i "passive_subs.txt" -o "altdns_subs.txt" -w "$WORDLIST" &
    wait
)
cat "gobuster_subs.txt" "altdns_subs.txt" | sort -u > "all_subs.txt"

### **Step 3: Live SubDOMAIN Verification**
log "[+] Step 3: Live SubDOMAIN Verification"
httpx -l "all_subs.txt" -o "live_subs.txt" -threads 50 -title -tech-detect -status-code -cdn

### **Step 4: Network Scanning & Fingerprinting**
log "[+] Step 4: Network Scanning & Fingerprinting"
(
    masscan -iL "live_subs.txt" --top-ports 100 -oG "masscan.txt" &
    naabu -l "live_subs.txt" -o "naabu.txt" &
    eyewitness --web -f "live_subs.txt" --threads 20 -d "screenshots" &
    aquatone -scan-timeout 500 -out "aquatone" -ports 80,443,8080,8443,3000 &
    wait
)

### **Step 5: Web Content Discovery**
log "[+] Step 5: Web Content Discovery"
(
    dirsearch -l "live_subs.txt" -e * -w "/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt" -o "dirsearch.txt" &
    ffuf -w "/usr/share/wordlists/SecLists/Discovery/Web-Content/common.txt" -u FUZZ -mc 200,301,403 -o "ffuf.txt" &
    wait
)

### **Step 6: SubDOMAIN Takeover**
log "[+] Step 6: SubDOMAIN Takeover"
(
    nuclei -l "live_subs.txt" -t "$NUCLEI_TEMPLATES/takeovers" -o "nuclei_takeovers.txt" &
    subzy run --targets "live_subs.txt" --output "subzy_takeovers.txt" &
    wait
)

### **Step 7: Vulnerability Scanning**
log "[+] Step 7: Vulnerability Scanning"
(
    nuclei -l "live_subs.txt" -t "$NUCLEI_TEMPLATES" -o "nuclei_vulns.txt" &
    nikto -h "live_subs.txt" -o "nikto_results.txt" &
    wait
)

### **Step 8: XSS, SQLi, & Other Exploit Tests**
log "[+] Step 8: XSS, SQLi, & Other Exploit Tests"
(
    # XSS
    cat "live_subs.txt" | waybackurls | grep "\?" | uro | tee "params.txt" |
    xargs -I{} dalfox url {} -b "YOUR_BURP_COLLABORATOR" --output "dalfox_{}.txt" &
    
    # SQL Injection
    sqlmap --batch --random-agent --level 2 --risk 2 -m "params.txt" --output-dir="sqlmap_results" &
    
    wait
)

### **Step 9: Shodan & Censys Intelligence**
log "[+] Step 9: Shodan & Censys Intelligence"
(
    if [[ -n "$SHODAN_API_KEY" ]]; then
        for ip in $(cat "live_subs.txt" | httpx -list-ips); do
            shodan host "$ip" --fields ip_str,ports,hostnames,vulns --api-key "$SHODAN_API_KEY" > "shodan_$ip.json" &
        done
        wait
    fi
)

### **Step 10: Cloud Bucket Enumeration**
log "[+] Step 10: Cloud Bucket Enumeration"
bucket_finder -d "$DOMAIN" -o "buckets.txt"

### **Step 11: API Key & Secret Leaks**
log "[+] Step 11: API Key & Secret Leaks"
gitleaks --repo="$DOMAIN" --report="gitleaks_report.json"

### **Step 12: Open Redirect & CORS Testing**
log "[+] Step 12: Open Redirect & CORS Testing"
(
    corscanner -i "live_subs.txt" -o "cors_results.txt" &
    qsreplace "https://evil.com" < "params.txt" | while read host; do
        curl -s -L "$host" -I | grep "evil.com" && echo "$host" >> "open_redirects.txt"
    done
)

log "[+] Advanced Recon Completed! Results saved in $OUTPUT_DIR"
