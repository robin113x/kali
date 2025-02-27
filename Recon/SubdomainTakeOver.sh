#!/bin/bash

# Get Subdomains from TLS Certificates
cero -p 443,4443,8443,10443 -c 1000

# Get Subdomains From CNAMES
dnsx -retry 3 -cname -l <input_file>
# Check For Subdomain Takeover
subjack -w <input_file> -t 100 -timeout 30 -ssl -c /path/to/fingerprints.json -v 3