#!/bin/bash
# Tiny utility to check if any ToR entry node IP addresses are in a capture file.
#  i.e. are any devices in the capture file using ToR.
#  The Tor list is a snapshot in time so may not work for old pcaps.

if [ $# -eq 0 ]
  then
    echo "[!] Error: Please supply capture file as input."
    exit
fi

INFILE=$1

echo "[+] Checking if any devices in $INFILE are using ToR"

if [ ! -f torlist.txt ]; then
  echo "[+] Downloading ToR entry node list..."
  wget -O torlist.txt https://www.dan.me.uk/torlist/ &>/dev/null
  #wget -O torlist.txt https://pastebin.com/raw/wVzeGh3A &>/dev/null
  if [ ! $? -eq 0 ]; then
    echo "[!] Error: Unable to download ToR list (https://www.dan.me.uk/torlist/). You might be throttled, try again in 30 mins."
    rm torlist.txt #Remove blank file
    exit
  fi
  sort torlist.txt -o torlist.txt
fi
echo "[+] Extracting IPs from $INFILE..."
#tshark -r $INFILE -Y "tcp"  -T fields -e ip.dst | sort | uniq > ips.txt
tshark -r $INFILE -Y "tcp"  -T fields -e ip.src -e ip.dst -E separator=,| sort | uniq > ippairs.txt
cat ippairs.txt | cut -d "," -f 2 | sort | uniq > ips.txt
echo "[-] ToR entry nodes: " `wc -l <torlist.txt`
echo "[+] IPs in capture file: " `wc -l <ips.txt`
echo "[+] Entry node ToR IPs in $INFILE:"
echo ""
cat torlist.txt ips.txt | sort | uniq -d > tors.txt # Hack to find intersection of sorted files
cat tors.txt

echo ""
echo "[+] Client IPs in $INFILE connecting to above ToR nodes:"

echo "">tmp.txt
for i in `cat tors.txt`
do
  grep $i ippairs.txt | cut -d "," -f 1 >> tmp.txt
done

grep -v -F -x -f tors.txt tmp.txt| sort | uniq # Such hax. Much wow.

#Cleanup
rm ips.txt tmp.txt ippairs.txt tors.txt
