#!/bin/bash

domain=$1

echo -e """\e[33m================================================\e[0m
                   \e[35msubrecon\e[0m
\e[33m================================================\e[0m
"""

sleep 2
echo -e "Script started - Root domain is \e[31m$domain\e[0m"
echo " "
sleep 2
echo -e "\e[32m[+] Running Subfinder\e[0m"
echo " "
sleep 2

subfinder -all -config /home/kali/Misc/config.yaml -d $domain -o subfinder.txt

echo " "
sleep 2
echo -e "\e[32m[+] Running PureDNS\e[0m"
echo " "
sleep 2

puredns bruteforce /home/kali/Misc/wordlists/ultimate-subs.txt $domain -r /home/kali/Misc/resolvers.txt -w puredns.txt

echo " "
sleep 2
echo -e "\e[32m[+] Running Amass\e[0m"
echo " "
sleep 2

amass enum -d $domain -passive -nolocaldb -config /home/kali/Misc/config.ini -o amass.txt

echo " "
sleep 2
echo -e "\e[33m[!] Cleaning subdomains\e[0m"
cat subfinder.txt > domains.txt
cat puredns.txt >> domains.txt
cat amass.txt >> domains.txt
cat domains.txt | sort -u > subdomains.txt
rm domains.txt
rm subfinder.txt
rm puredns.txt
rm amass.txt

echo " "
sleep 3
echo -e "\e[32m[+] My work is done...\e[0m"
echo " "
