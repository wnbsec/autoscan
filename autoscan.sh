#!/bin/bash
host=$1
TCP=()
UDP=()
file="$host-allports.txt"

if [ "$1" == "" ]; then
	echo "$0: automated masscan/nmap scan (all TCP/UDP, OS/version, scripts, traceroute)"
	echo "Syntax: $0 <IP>"
	exit 1
fi

masscan -oL $file -p1-65535,U:1-65535 $host --rate=1000

while IFS= read -r line
do
	protocol=$(echo $line | cut -d " " -f 2)
        port=$(echo $line | cut -d " " -f 3)
	if [[ $protocol == "tcp" ]] || [[ $protocol == "udp" ]]; then
		if [ $protocol == "tcp" ]; then
			TCP=(${TCP[@]} $port)
		elif [ $protocol == "udp" ]; then
			UDP=(${UDP[@]} $port)
		else
			continue
		fi
	else
		continue
	fi
done < $file

rm -f $file

IFS=$'\n'
echo -e "\n--------------------------------------------------------------------------------"
echo "[*] TCP Ports Open: $(echo $(sort -g <<<"${TCP[*]}"))"
echo "[*] UDP Ports Open: $(echo $(sort -g <<<"${UDP[*]}"))"
echo -e "--------------------------------------------------------------------------------\n"

TCP=$(echo $(sort -g <<<"${TCP[*]}") | sed 's/ /,/g')
if [ ${#UDP[@]} -gt 0 ]; then
	UDP=$(echo "U:"$(echo $(sort -g <<<"${UDP[*]}") | sed 's/ /,/g'))
else
	UDP=""
fi

nmap  -T4 -p$TCP -A $host > $host.txt

echo -e "\n-----------------------------------------------------------------\n" >> $host.txt

if [ "$UDP" != "" ]; then
	nmap -sU -T4 -p$UDP -A $host >> $host.txt
fi

cat $host.txt
