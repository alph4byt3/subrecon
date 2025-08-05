#!/bin/bash

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                ALPHARECON                                                  +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo -e "\e[1;32m                      A script for automated domain reconnaissance. Created by alph4byt3\e[0m"

list=("intigriti.com")

for domain in ${list[@]}; do

  echo " "
  echo -e "Started processing on domain - \e[31m$domain\e[0m"
  echo " ";

  echo -e "\e[32m[+] Running Bruteforce...\e[0m"
  shuffledns -mode bruteforce -d $domain -w /usr/share/seclists/Discovery/DNS/best-dns-wordlist.txt -o bruteforced-subdomains.txt -silent > /dev/null

  echo -e "\e[32m[+] Running Subfinder...\e[0m"
  subfinder -d $domain -all -o subfinder-subdomains.txt -silent > /dev/null

  echo -e "\e[32m[+] Running Amass...\e[0m"
  amass enum -d $domain -o amass-subdomains.txt > /dev/null

  cat amass-subdomains.txt >> subfinder-subdomains.txt
  cat subfinder-subdomains | sort -u > for-resolving.txt

  echo -e "\e[32m[+] Running Shuffledns...\e[0m"
  shuffledns -mode resolve -list for-resolving.txt -r ~/Tools/resolvers.txt -o resolved.txt -silent > /dev/null

  cat bruteforced-subdomains.txt >> resolved.txt
  cat resolved.txt | sort -u > for-portscanning.txt

  echo -e "\e[32m[+] Running Naabu...\e[0m"
  naabu -list for-portscanning.txt -port 1,7,19,20,21,22,23,25,30,42,43,53,67,68,69,80,81,82,88,102,110,113,119,123,135,137,138,139,143,161,162,177,179,183,194,201,264,389,411,412,427,443,444,445,464,465,500,514,546,547,554,560,563,5683,587,593,623,636,647,6850,691,8000,8001,8005,8006,8009,8080,8081,8083,8085,8086,8087,8089,8111,8180,8181,8222,8280,8380,8443,8686,873,8880,8883,8899,9000,9001,9002,9004,902,9030,9071,9072,9073,9074,9090,9091,9092,9093,9100,9104,9105,9115,9182,9375,9389,9405,9406,9407,9418,9443,9600,993,995,10000,1024,1025,1026,1027,1028,1029,1080,11211,1194,12100,12101,12102,12103,12104,12105,1214,12345,1241,1311,13131,1337,1433,1434,15000,1521,15672,1589,1645,1646,1701,1720,1723,1725,1812,1813,1883,1900,2049,2052,2053,2077,2078,2082,2083,2086,2087,2095,2096,2483,2484,2535,25565,27017,27374,2967,3074,3100,3128,3233,32400,3268,3269,3306,3343,3389,3700,3724,37777,37778,3820,3920,4000,44158,4500,4664,4712,4713,4840,4843,49152,5001,5060,5222,5223,5432,5631,5632,5672,5678,57222,5800,5900,5938,5985,5988,5989,6060,6379,6443,6543,6665,6666,6667,6668,6669,6881,6999,7070,7276,7286,7500,7676 -verify -rate 1000 -o portscan.txt -silent > /dev/null

  echo -e "\e[32m[+] Running Httpx...\e[0m"
  httpx -list portscan.txt -mc 200,401,403 -rate-limit 100 -o live_urls_$domain.txt -silent > /dev/null

  rm bruteforced-subdomains.txt
  rm subfinder-subdomains.txt
  rm amass-subdomains.txt
  rm subdomains.txt
  rm resolved.txt
  rm for-portscanning.txt
  rm portscan.txt
  echo "Processing on $domain done!"
done
