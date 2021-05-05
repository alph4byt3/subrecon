#!/bin/bash

domain=$1

echo -e """\e[33m================================================\e[0m
                   \e[35msubrecon\e[0m
\e[33m================================================\e[0m
"""

sleep 3
echo -e "Script started - Root domain is \e[31m$domain\e[0m"
echo " "
echo -e "\e[32m[+] Running Subfinder\e[0m"
echo " "
sleep 3

subfinder -all -config /home/kali/Misc/config.yaml -d $domain -o subfinder.txt

sleep 3
echo " "
echo -e "\e[32m[+] Running PureDNS\e[0m"
echo " "
sleep 3

puredns bruteforce /home/kali/Misc/wordlists/ultimate-subs.txt $domain -r /home/kali/Misc/resolvers.txt -w puredns.txt

echo " "
sleep 3
echo -e "\e[33m[!] Cleaning subdomains\e[0m"
cat subfinder.txt > domains.txt
cat puredns.txt >> domains.txt
cat domains.txt | sort -u > subdomains.txt
rm domains.txt
rm subfinder.txt
rm puredns.txt

echo " "
sleep 3
echo -e "\e[32m[+] Running httpx\e[0m"
echo " "

httpx -l subdomains.txt -fc 301,302 -threads 1 -o urls.txt -silent

echo " "
sleep 3
echo -e "\e[32m[+] My work is done...\e[0m"
echo " "
