#!/bin/bash
export PATH=$PATH:/root/go/bin
export PDCP_API_KEY="fdad7624-5d84-4744-9d31-d1da42481d3d"

baseDir="/root/recon"
scriptsDir="/root/recon/scripts"

source /root/myenv/bin/activate

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

if [[ ! -d "$baseDir" ]]; then
    echo -e "${RED}[\u2718] Directory '$baseDir' does not exist.${NC}"
    exit 1
fi

for dir in "$baseDir"/*/; do
    programName=$(basename "$dir")

    # Skip the scripts directory
    [[ "$programName" == "scripts" ]] && continue

    rootDomains="${dir}/rootdomain.txt"
    lastNotifiedFile="${dir}/last_notified_metadata.txt"

    if [[ ! -f "$rootDomains" ]]; then
        echo -e "${YELLOW}[!] No rootdomain.txt found for ${programName}${NC}"
        continue
    fi

    echo -e "${CYAN}\n🔍 [$programName] Starting recon...${NC}"

    echo -e "${BLUE}    [+] Gathering subdomains...${NC}"
    subfinder -dL "$rootDomains" -all -silent | sort -u >> "${dir}/all_subs.txt"

    echo -e "${BLUE}    [+] Resolving domains...${NC}"
    dnsx -l "${dir}/all_subs.txt" -silent | sort -u >> "${dir}/resolved.txt"

    echo -e "${BLUE}    [+] Running httpx for HTTP probing...${NC}"
    ~/go/bin/httpx -l "${dir}/resolved.txt" -sc -title -ct -location -server -td -method -ip -cname -asn -cdn > "${dir}/metadata.txt"

    # Strip ANSI colors
    sed 's/\x1B\[[0-9;]*[JKmsu]//g' "${dir}/metadata.txt" > "${dir}/metadata.tmp"

    echo -e "${BLUE}    [+] Separating status codes...${NC}"
    for code in 200 301 302 401 403 404 502 503; do
        grep "\[$code\]" "${dir}/metadata.tmp" | cut -d " " -f 1 | cut -d "/" -f 3 > "${dir}/${code}.txt"
    done

    echo -e "${BLUE}    [+] Checking for new [200] OKs...${NC}"

    # Extract URLs from 200 entries
    grep '\[200\]' "${dir}/metadata.tmp" | awk '{print $1}' | sort -u > "${dir}/urls_200.txt"

    # Make sure the last notified metadata file exists
    touch "$lastNotifiedFile"

    # Extract URLs from previously notified metadata
    awk '{print $1}' "$lastNotifiedFile" | sort -u > "${dir}/urls_last.txt"

    # Compare and get new ones
    comm -23 "${dir}/urls_200.txt" "${dir}/urls_last.txt" > "${dir}/new_urls.txt"

    # Get full metadata lines for new URLs
    grep -Ff "${dir}/new_urls.txt" "${dir}/metadata.tmp" > "${dir}/new_200_metadata.txt"

    if [[ -s "${dir}/new_200_metadata.txt" ]]; then
        newCount=$(wc -l < "${dir}/new_200_metadata.txt")
        echo -e "${GREEN}    [\u2714] Found $newCount new [200] entries!${NC}"
        echo -e "${BLUE}    [+] Sending notifications...${NC}"
        cat "${dir}/new_200_metadata.txt" | notify -bulk -pc "${baseDir}/provider-config.yaml" -v
        cat "${dir}/new_200_metadata.txt" >> "$lastNotifiedFile"
        sort -u "$lastNotifiedFile" -o "$lastNotifiedFile"
    else
        echo -e "${YELLOW}    [-] No new [200] entries found.${NC}"
    fi

    # Cleanup temp files
    rm -f "${dir}/urls_200.txt" "${dir}/urls_last.txt" "${dir}/new_urls.txt"

    echo -e "${BLUE}    [+] Inserting into DB...${NC}"
    python3 "${scriptsDir}/insert.py" "${dir}/all_subs.txt" "$programName"

    echo -e "${BLUE}    [+] Updating status codes...${NC}"
    python3 "${scriptsDir}/update.py" "$dir" "$programName"

    echo -e "${CYAN}✅ [$programName] Done.${NC}\n"
done
