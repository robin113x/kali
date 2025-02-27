#!/bin/bash

# Get Subdomains from TLS Certificates
cero -p 443,4443,8443,10443 -c 1000 #from:@passive #as:@activesubs{unique}

# Get Subdomains From CNAMES
dnsx -retry 3 -cname -l <input_file>