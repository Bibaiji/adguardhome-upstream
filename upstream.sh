#!/bin/bash
set -e
DATE=`date --rfc-3339 sec`
echo "$DATE: IPv4 connection testing..."
if ping -c 3 "dns.alidns.com" > /dev/null 2>&1; then
	IPv4="true"
fi
echo "$DATE: IPv6 connection testing..."
if ping6 -c 3 "dns.alidns.com" > /dev/null 2>&1; then
	IPv6="true"
fi
if [[ $IPv4 == "true" ]]; then
	if [[ $IPv6 == "true" ]]; then
		echo "$DATE: IPv4 and IPv6 connections both available."
		curl -o "/var/tmp/default.upstream" https://raw.githubusercontent.com/Bibaiji/adguardhome-upstream/master/v6.conf > /dev/null 2>&1
	else
		echo "$DATE: IPv4 connection available."
		curl -o "/var/tmp/default.upstream" https://raw.githubusercontent.com/Bibaiji/adguardhome-upstream/master/v4.conf > /dev/null 2>&1
	fi
else
	if [[ $IPv6 == "true" ]]; then
		echo "$DATE: IPv6 connection available."
		curl -o "/var/tmp/default.upstream" https://raw.githubusercontent.com/Bibaiji/adguardhome-upstream/master/v6only.conf > /dev/null 2>&1
	else
		echo "ERROR: No available network connection was detected, please try again."
		exit 1
	fi
fi
echo "$DATE: Getting data updates..."
curl -o "/var/tmp/1.upstream" https://github.com/Potterli20/file/releases/download/dns-hosts/dns-adguardhome-whitelist_full.txt > /dev/null 2>&1
echo "$DATE: Download lists"
curl -s https://raw.githubusercontent.com/Bibaiji/Chinese-list/master/CHN.ALL.agh | sed "/#/d" > "/var/tmp/2.upstream"
echo "$DATE: Processing data format..."
cat "/var/tmp/default.upstream" "/var/tmp/1.upstream" "/var/tmp/2.upstream" > /usr/share/adguardhome.upstream
if ! [[ $IPv4 == "true" ]]; then sed -i "s|8.8.8.8|2001:4860:4860::8888|g" /usr/share/adguardhome.upstream; fi
echo "$DATE: Cleaning..."
rm /var/tmp/*.upstream
systemctl restart AdGuardHome
echo "$DATE: All finished!"
