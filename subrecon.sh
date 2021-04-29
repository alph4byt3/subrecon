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

subfinder -all -config /home/kali/Misc/config.yaml -d $domain -silent -o subfinder.txt

sleep 3
echo " "
echo "[+] Running ShuffleDNS"
echo " "
sleep 3

shuffledns -d $domain -w /home/kali/Misc/wordlists/ultimate-subs.txt -r /home/kali/Misc/resolvers.txt -o shuffledns.txt -silent

echo " "
sleep 3
echo "[!] Cleaning subdomains"
cat subfinder.txt > domains.txt
cat shuffledns.txt >> domains.txt
cat domains.txt | sort -u > subdomains.txt
rm domains.txt
rm subfinder.txt
rm shuffledns.txt

echo " "
sleep 3
echo "[+] Running httpx"
echo " "

httpx -l subdomains.txt -fc 301,302 -threads 1 -o urls.txt -silent

echo " "
sleep 3
echo "[+] My work here is done..."
echo " "
