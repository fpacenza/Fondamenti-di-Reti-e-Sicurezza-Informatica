#!/bin/sh

### REGOLE DEL FIREWALL F2 ###
# Pulizia del firewall
iptables -F # Flush
iptables -X # Cancella tutte le catene

## Setting delle policy di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Abilitare ssh in F2 (parte 2)
iptables -A INPUT -p tcp -i eth0 --dport 22 -j ACCEPT 
iptables -A OUTPUT -p tcp -o eth0 --sport 22 -j ACCEPT 

# Creazione delle sottocatene
iptables -N greenAll
iptables -N allGreen
iptables -N DMZred
iptables -N redDMZ


# Aggancio delle sottocatene create dall'utente alle catene di default
iptables -A FORWARD -s 10.0.6.0/24 -i eth0 -o eth1 -j greenAll
iptables -A FORWARD -d 10.0.6.0/24 -i eth1 -o eth0 -j allGreen
iptables -A FORWARD -i eth0 -o eth1 -s 10.0.4.0/23 -d 10.0.0.0/22 -j DMZred
iptables -A FORWARD -o eth0 -i eth1 -d 10.0.4.0/23 -s 10.0.0.0/22 -j redDMZ

# Applicazione delle regole
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A DMZred -j ACCEPT
iptables -A redDMZ -m state --state ESTABLISHED,RELATED -j ACCEPT


# Abilitare nuove richieste (echo request 8) ICMP da RED verso DMZ
iptables -A redDMZ -p icmp --icmp-type 8 -j ACCEPT

# Abilitare le risposte (echo reply 0) ICMP da DMZ  verso RED
iptables -A DMZred -p icmp --icmp-type 0 -j ACCEPT