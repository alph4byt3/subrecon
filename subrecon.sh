#!/bin/bash

domain=$1

echo """================================================
                   alph4byt3
================================================
"""

sleep 3
echo "Script started - Root domain is $domain"
echo " "
echo "[+] Running Subfinder"
echo " "
sleep 3

subfinder -d $domain -silent -o domains.txt

echo " "
sleep 3
echo "[!] Cleaning subdomains"
cat domains.txt | sort -u > subdomains.txt
rm domains.txt

echo " "
sleep 3
echo "[+] Running dnsx"
echo " "

dnsx -l subdomains.txt -r /home/kali/Misc/resolvers.txt -o resolved-subdomains.txt -t 1 -silent

echo " "
sleep 3
echo "[!] Subdomains resolved"
rm subdomains.txt

echo " "
sleep 3
echo "[+] Running httpx"
echo " "

httpx -l resolved-subdomains.txt -fc 301,302 -threads 1 -o urls.txt -silent

echo " "
sleep 3
echo " "
