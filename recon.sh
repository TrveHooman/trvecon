#!/bin/bash

DOMAIN=$1
RED="\033[1;31m"
LIME="\e[92m"
RESET="\033[0m"

SUB_PATH=$DOMAIN/subdomains/
SCR_PATH=$DOMAIN/screenshots/
SCN_PATH=$DOMAIN/scans/

if [ ! -d "$DOMAIN" ];then
    mkdir $DOMAIN
fi
if [ ! -d "$SUB_PATH" ];then
    mkdir $SUB_PATH
fi
if [ ! -d "$SCR_PATH" ];then
    mkdir $SCR_PATH
fi
if [ ! -d "$SCN_PATH" ];then
    mkdir $SCN_PATH
fi

echo -e "${RED}[+] Running ${LIME}subfinder${RED} on '$DOMAIN' into: ${LIME}'$SUB_PATH'${RESET}"
subfinder -d $DOMAIN > $SUB_PATH/subdomains.txt

echo -e "${RED}[+] Running ${LIME}assetfinder${RED} on '$DOMAIN' into: ${LIME}'$SUB_PATH'${RESET}"
assetfinder $DOMAIN | grep $DOMAIN >> $SUB_PATH/subdomains.txt

#echo -e "${RED}[+] Running ${LIME}amass${RED} on '$DOMAIN' into: ${LIME}'$SUB_PATH'${RESET}"
#amass enum -d $DOMAIN >> $SUB_PATH/subdomains.txt

echo -e "${RED}[+] Running ${LIME}httprobe${RED} on subdomains.txt into: ${LIME}'$SUB_PATH'${RESET}"
cat $SUB_PATH/subdomains.txt | grep $DOMAIN | sort -u | httprobe --prefer-https | grep https | sed 's/https\?:\/\///' | tee -a $SUB_PATH/alive.txt

echo -e "${RED}[+] Running ${LIME}gowtiness${RED} on '$DOMAIN' into: ${LIME}'$SCR_PATH'${RESET}"
gowitness file -f $SUB_PATH/alive.txt -P $SCR_PATH/ --no-http --timeout 10

echo -e "${RED}[+] Running ${LIME}nmap${RED} on '$DOMAIN' into: ${LIME}'$SCN_PATH'${RESET}"
nmap -iL $SUB_PATH/alive.txt -T4 -p 80,443 -oN $SCN_PATH/nmap.txt