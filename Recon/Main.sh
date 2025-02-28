#!/bin/bash

# Configuration
DOMAIN="$1"
echo "Domain: $DOMAIN"
OUTPUT_DIR="results/$DOMAIN"
LOG_FILE="recon.log"
NUCLEI_TEMPLATES="/root/nuclei-templates
$SHODAN_API