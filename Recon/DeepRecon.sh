#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

domain=$1
output="/home/robin/kali/BugBounty/$domain"
mkdir -p "$output"
cd "$output"

pwd
sleep 5



echo "********************************Passive Enumeration*********************************************"
curl -s "https://crt.sh/?q=%.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee "crtsh_passive.txt"
curl -s "https://otx.alienvault.com/api/v1/indicators/hostname/$domain/passive_dns" | jq -r '.passive_dns[]?.hostname' | sort -u | tee "alienvault_passive.txt"
curl -s "https://urlscan.io/api/v1/search/?q=domain:$domain&size=10000" | jq -r '.results[]?.page?.domain' | sort -u | tee "urlscan_passive.txt"
curl -s "http://web.archive.org/cdx/search/cdx?url=*.${domain}/*&output=json&collapse=urlkey" | jq -r '.[1:][] | .[2]' | sort -u | tee "wayback_passive.txt"
wait

echo "********************************Active Enumeration*********************************************"

# Active Enumeration
subfinder -d "$domain" -all -recursive -o "subfinder.txt"
sublist3r -d "$domain" -p 80,443  -v  | tee "sublist3r.txt"
assetfinder -subs-only "$domain" | tee "assetfinder.txt"
shodanx subdomain -d "$domain" -ra -o "shodanx.txt"
knockpy -d "$domain" | tee "knockpy.txt"
amass enum -norecursive -d "$domain" -o "amass.txt" 
wait


#combine all Result
cat *.txt | anew all_subdomains.txt


#subdomain of subdomain

altdns -i all_subdomains.txt -o data_output -w /usr/share/wordlist/words.txt -r -s altdns_results_output.txt


echo "**********waybackurls & waybackrobots ******************"
waybackrobots -d "$domain" | tee "waybackrobots.txt"
cat domains.txt |  waybackurls |tee  urls_wayback.txt


