#!/bin/bash

# Configuration
DOMAIN="$1"
echo "Domain: $DOMAIN"
OUTPUT_DIR="results/$DOMAIN"
LOG_FILE="recon.log"
NUCLEI_TEMPLATES="/root/nuclei-templates
SHODAN_API="22905caf0b00f7f97261d498140046a07925b8c22f8d21b12fcad6b1b8357105"
