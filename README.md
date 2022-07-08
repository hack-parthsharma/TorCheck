# TorCheck
Check if any IPs in a capture file are using ToR. e.g output:

```
./torCheck.sh tor_data.pcap
[+] Checking if any devices in tor_data.pcap are using ToR
[+] Extracting IPs from tor_data.pcap...
[-] ToR entry nodes:  6291
[+] IPs in capture file:  83
[+] Entry node ToR IPs in tor_data.pcap:

192.42.115.101
81.7.10.251

[+] Client IPs in tor_data.pcap connecting to above ToR nodes:

192.168.0.5

```
