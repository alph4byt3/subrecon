#!/bin/bash

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                ALPHARECON                                                  +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo -e "\e[1;32m                      A script for automated domain reconnaissance. Created by alph4byt3\e[0m"

list=("dropbox.com")

for domain in ${list[@]}; do
  
  echo " "
  echo -e "Started processing on domain - \e[31m$domain\e[0m"
  echo " ";
  
  echo -e "\e[32m[+] Running Bruteforce...\e[0m"
  puredns bruteforce ~/Wordlists/best-dns-wordlist.txt -r ~/Wordlists/resolvers.txt -l 12000 $domain -w bruteforced-subdomains.txt &> /dev/null
  
  echo -e "\e[32m[+] Running Subfinder...\e[0m"
  subfinder -d $domain -silent | grep '.$domain' > subfinder-subdomains.txt
  
  echo -e "\e[32m[+] Running PureDNS...\e[0m"
  puredns resolve -r ~/Wordlists/resolvers.txt -l 12000 subfinder-subdomains.txt -w resolved.txt &> /dev/null
  
  cat bruteforced-subdomains.txt >> resolved.txt
  cat resolved.txt | sort -u > for-portscanning.txt
  
  echo -e "\e[32m[+] Running Naabu...\e[0m"
  naabu -list for-portscanning.txt -port 80,8080,443,8443,81,82,8000,4443,4433,8008,3000,10000,19999,18888,4317,2082,2083,2086,2087,2095,2096,2077,2078,3128,9060,9080,12100,12101,12104,12105,9999,9099,7777,631,9090,9443,5550,5554,8009,3306,5432,1521,1433,1434,27017,7013,7103,7104,8765,1080 -verify -rate 1200 -o portscan.txt -silent > /dev/null
  
  echo -e "\e[32m[+] Running Httpx...\e[0m"
  httpx -list portscan.txt -rate-limit 120 -silent | sort -u > live_urls_$domain.txt
  
  rm bruteforced-subdomains.txt
  rm subfinder-subdomains.txt
  rm resolved.txt
  rm for-portscanning.txt
  rm portscan.txt
  echo "Processing on $domain done!"
done
