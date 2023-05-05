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
		curl -o "/var/tmp/default.upstream" https://jihulab.com/Bibaiji/adguardhome-upstream/-/raw/master/v6.conf > /dev/null 2>&1
	else
		echo "$DATE: IPv4 connection available."
		curl -o "/var/tmp/default.upstream" https://jihulab.com/Bibaiji/adguardhome-upstream/-/raw/master/v4.conf > /dev/null 2>&1
	fi
else
	if [[ $IPv6 == "true" ]]; then
		echo "$DATE: IPv6 connection available."
		curl -o "/var/tmp/default.upstream" https://jihulab.com/Bibaiji/adguardhome-upstream/-/raw/master/v6only.conf > /dev/null 2>&1
	else
		echo "ERROR: No available network connection was detected, please try again."
		exit 1
	fi
fi
echo "$DATE: Getting data updates..."
wget https://jihulab.com/Bibaiji/Chinese-list/-/raw/master/Potterli20-White.agh -O/var/tmp/1.upstream
echo "$DATE: 1.upstream finished"
wget https://jihulab.com/Bibaiji/Chinese-list/-/raw/master/CHN.ALL.agh -O/var/tmp/2.upstream
echo "$DATE: 2.upstream finished"
wget https://jihulab.com/Bibaiji/adguardhome-upstream/-/raw/master/ChinaAdd.agh -O/var/tmp/3.upstream
echo "$DATE: 3.upstream finished"
cat "/var/tmp/default.upstream" "/var/tmp/1.upstream" "/var/tmp/2.upstream" "/var/tmp/3.upstream" > /usr/share/adguardhome.upstream
echo "$DATE: Cleaning..."
rm /var/tmp/*.upstream
systemctl restart AdGuardHome
echo "$DATE: All finished!"
