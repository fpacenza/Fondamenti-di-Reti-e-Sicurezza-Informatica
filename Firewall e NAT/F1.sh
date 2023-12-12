#!/bin/sh

### REGOLE DEL FIREWALL F1 ###
# Pulizia del firewall

iptables -F # Flush
iptables -X # Cancella tutte le catene

## Setting delle policy di default
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Abilitare ssh in F1
iptables -A INPUT -p tcp --dport 22 -s 10.0.7.12/30 -i eth0 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -d 10.0.7.12/30 -o eth0 -j ACCEPT

# Creazione delle sottocatene
iptables -N greenAll
iptables -N allGreen
iptables -N inetDMZ
iptables -N DMZinet

# Aggancio delle sottocatene create dall'utente alle catene di default
iptables -A FORWARD -s 10.0.6.0/24 -i eth1 -j greenAll
iptables -A FORWARD -d 10.0.6.0/24 -o eth1 -j allGreen
iptables -A FORWARD -i eth0 -o eth2 -d 10.0.4.0/23 -j inetDMZ
iptables -A FORWARD -o eth0 -i eth2 -s 10.0.4.0/23 -j DMZinet


# Applicazione delle regole
iptables -A greenAll -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A inetDMZ -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A DMZinet -m state --state ESTABLISHED,RELATED -j ACCEPT

# Abilitare SSH su Firewall F2 (parte 1)
iptables -A FORWARD -p tcp --dport 22 -i eth0 -o eth2 -d 10.0.7.6 -j ACCEPT
iptables -A FORWARD -p tcp --sport 22 -i eth2 -o eth0 -s 10.0.7.6 -m state --state ESTABLISHED,RELATED -j ACCEPT


# Natting
## DNAT
## Portforwarding della porta 80 su 10.0.5.3
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.0.5.3

## Portforwarding della porta 4443 su 10.0.4.2:443
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 4443 -j DNAT --to 10.0.4.2:443

## Portforwarding della porta 2525 su 10.0.5.2
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 2525 -j DNAT --to 10.0.5.2

## SNAT
## Cambia l'indirizzo sorgente in 10.0.0.1
# iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to 10.0.0.1

## Cambia l'indirizzo sorgente in 10.0.0.1, 10.0.0.2 oppure 10.0.0.3
# iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to 10.0.0.1-10.0.0.3

## Cambia l'indirizzo sorgente in 10.0.0.1, e la porta in 8080
# iptables -t nat -A POSTROUTING -p tcp -o eth0 -j SNAT --to 10.0.0.1:8080

## Cambia l'indirizzo sorgente in 10.0.0.1, porte 1-1023
# iptables -t nat -A POSTROUTING -p tcp -o eth0 -j SNAT --to 10.0.0.1:1-1023
