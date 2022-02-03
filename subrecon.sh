#!/bin/bash

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                SUBRECON                                                    +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "- alph4byt3"

sleep 1

echo " "
echo "Script starting"
echo " "

domain=$1

echo -e "Domain - \e[31m$domain\e[0m"
echo " "

echo -e "\e[32m[+] Running Amass\e[0m"
echo "Command: amass enum -d $domain -config ~/Misc/config.ini -nolocaldb -passive -o amass.txt"
echo " "

amass enum -d $domain -config /home/kali/Misc/config.ini -nolocaldb -passive -o amass.txt

echo " "
echo -e "\e[32m[+] Running Subfinder\e[0m"
echo "Command: subfinder -d $domain -all -config ~/Misc/config.yaml -o subfinder.txt"
echo " "

subfinder -d $domain -all -config /home/kali/Misc/config.yaml -silent -o subfinder.txt

echo " "
echo -e "\e[32m[+] Cleaning Amass and Subfinder results\e[0m"
sleep 1
echo " "

cat amass.txt >> subfinder.txt
cat subfinder.txt | sort -u > for-resolving.txt
rm amass.txt
rm subfinder.txt

echo " "
echo -e "\e[32m[+] Using PureDNS to resolve subdomains\e[0m"
echo "Command: puredns resolve for-resolving.txt -r ~/Misc/resolvers.txt -l 50 --rate-limit-trusted 50 -w resolved.txt"
echo " "

puredns resolve for-resolving.txt -q -r /home/kali/Misc/resolvers.txt -l 50 --rate-limit-trusted 50 -w resolved.txt

rm for-resolving.txt

echo " "
echo -e "\e[32m[+] Using PureDNS to bruteforce subdomains\e[0m"
echo "Command: puredns bruteforce ~/Misc/wordlists/ultimate-subdomain-wordlist.txt -r ~/Misc/resolvers.txt -w puredns.txt"
echo " "

puredns bruteforce /home/kali/Misc/wordlists/ultimate-subdomain-wordlist.txt $domain -r /home/kali/Misc/resolvers.txt -w puredns.txt

echo " "
echo -e "\e[32m...Doing some backend magic...\e[0m"
echo " "
sleep 1

cat puredns.txt >> resolved.txt
rm puredns.txt
cat resolved.txt | sort -u > subdomains.txt
rm resolved.txt

echo " "
echo -e "\e[32m[+] Portscanning with Unimap\e[0m"
echo "Command: sudo unimap --fast-scan -f subdomains.txt --ports "1-65535" --url-output -q -k | tee portscan.txt"
echo " "

sudo unimap --fast-scan -f subdomains.txt --ports "1-65535" --url-output -q -k | tee portscan.txt

echo -e "\e[32m[+] Probing using Htppx\e[0m"
echo "Command: httpx -l portscan.txt -retries 5 -random-agent -proxy 'http://8zbh8:j8yqfh6q@45.89.241.37:5432' -mc 200,301,302,401,403,404 -silent | sort -u > endpoints.txt"
echo " "

httpx -l portscan.txt -retries 5 -t 150 -rl 500 -random-agent -proxy 'http://8zbh8:j8yqfh6q@45.89.241.37:5432' -mc 200,301,302,401,403,404 -silent | sort -u > endpoints-$domain.txt

echo -e "\e[32m...Cleaning up...\e[0m"
echo " "
rm portscan.txt
rm subdomains.txt
rm -r unimap_logs
sleep 1

echo "Your endpoints are now stored in endpoints-$domain.txt"
