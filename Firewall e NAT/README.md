# Firewall e NAT - Topologia Progetto

## Prerequisiti
- Aver completato l'esercitazione [Internet e TAP](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/tree/main/Internet%20e%20TAP)
- Aver completato il modulo [Netfilter - Concetti Base](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/tree/main/Netfilter)

## Obiettivo
### Configurare i firewall `F1` ed `F2` così da ottenere la seguente connettività tra le diverse aree:
- L'area `GREEN` può aprire *nuove comunicazioni* verso tutte le altre aree della rete e deve solo *rispondere* a comunicazioni precedentemente avviate da lei stessa
- Tutte le altre aree non devono essere in grado di instaurare *nuove comunicazioni* direttamente con l'area `GREEN`
- L'area `DMZ` è abilitata a ricevere nuove comunicazioni in entrata da parte di `INTERNET` (e anche di `GREEN` la quale può counicare con tutti)
- L'area `RED` può ricevere nuove comunicazioni solo da parte dell'area `DMZ`
- Bisogna abilitare l'accesso reomto `SSH - porta 22` sul firewall `F2`
- Bisogna abilitare l'area `RED` ad effettuare nuove richieste di `ping` (`echo-request`) verso l'area `DMZ`
- L'area `DMZ` può solo rispondere alle richieste di `ping` (`echo-reply`) ricevute dall'area `RED` 

### Natting
- Abilitare il portforwarding della porta `80` sull'indirizzo `10.0.5.3`
- Abilitare il portforwarding della porta `4443` sull'indirizzo `10.0.4.2` traslando la porta sulla `443`
- Abilitare il portforwarding della porta `2525` sull'indirizzo `10.0.5.2`

## Topologia della rete
![alt text](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Routing/project_topology_gns3.png?raw=true)

## Configurazione del Firewall `F1`
- Avviamo il progetto tramite `GNS3` ed colleghiamoci al terminale del firewall `F1`
- Creiamo un nuovo file dal nome `firewall.sh` nella cartella `/etc/network`
```console
touch /etc/network/firewall.sh
```

### Impostazione delle policy di default di `iptables`
- Apriamo il file precedentemente creato così da poterlo modificare
```console
pico /etc/network/firewall.sh
```

- Scriviamo le regole per ripulire il firewall in caso di refusi
```console
iptables -F # Flush
iptables -X # Cancella tutte le catene
```

- Impostiamo le policy di default su `DROP` per tutte le catene di default del firewall (`INPUT`, `OUTPUT`, `FORWARD`) 
```console
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
```

- Abilitiamo il servizio `SSH` sul firewall `F1` (può essere necessario se si buole usare `sshfs`) e sul firewall `F2` 
```console
# Abilitare SSH su Firewall F1
iptables -A INPUT -p tcp --dport 22 -s 10.0.7.12/30 -i eth0 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -d 10.0.7.12/30 -o eth0 -j ACCEPT

# Abilitare SSH su Firewall F2 (parte 1)
iptables -A FORWARD -p tcp --dport 22 -i eth0 -o eth2 -d 10.0.7.6 -j ACCEPT
iptables -A FORWARD -p tcp --sport 22 -i eth2 -o eth0 -s 10.0.7.6 -m state --state ESTABLISHED,RELATED -j ACCEPT
```

- Creiamo le sottocatene da agganciare a `FORWARD`
```console
iptables -N greenAll
iptables -N allGreen
iptables -N inetDMZ
iptables -N DMZinet
```

- Agganciamo le catene a quella di `FORWARD`
```console
iptables -A FORWARD -s 10.0.6.0/24 -i eth1 -j greenAll
iptables -A FORWARD -d 10.0.6.0/24 -o eth1 -j allGreen
iptables -A FORWARD -i eth0 -o eth2 -d 10.0.4.0/23 -j inetDMZ
iptables -A FORWARD -o eth0 -i eth2 -s 10.0.4.0/23 -j DMZinet
```

- Applichiamo le regole con le giuste policy di `ACCEPT`
```console
iptables -A greenAll -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A inetDMZ -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A DMZinet -m state --state ESTABLISHED,RELATED -j ACCEPT
```

- Creiamo le regole di `NATTING` per il portforwarding
```console
# Natting
## Portforwarding della porta 80 su 10.0.5.3
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.0.5.3

## Portforwarding della porta 4443 su 10.0.4.2:443
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 4443 -j DNAT --to 10.0.4.2:443

## Portforwarding della porta 2525 su 10.0.5.2
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 2525 -j DNAT --to 10.0.5.2
```

- Salviamo il file (`CTRL+O`) e chiudiamolo (`CTRL+X`)
- Avviamo lo script del firewall con `sh /etc/network/firewall.sh`
- Per renderlo eseguibile automaticamente all'avvio, aggiungere in fondo al file `/etc/network/interfaces` la riga
```console
 post-up sh /etc/network/firewall.sh
```

## Configurazione del Firewall `F2`
- Avviamo il progetto tramite `GNS3` ed colleghiamoci al terminale del firewall `F1`
- Creiamo un nuovo file dal nome `firewall.sh` nella cartella `/etc/network`
```console
touch /etc/network/firewall.sh
```

### Impostazione delle policy di default di `iptables`
- Apriamo il file precedentemente creato così da poterlo modificare
```console
pico /etc/network/firewall.sh
```

- Scriviamo le regole per ripulire il firewall in caso di refusi
```console
iptables -F # Flush
iptables -X # Cancella tutte le catene
```

- Impostiamo le policy di default su `DROP` per tutte le catene di default del firewall (`INPUT`, `OUTPUT`, `FORWARD`) 
```console
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
```

- Abilitiamo il servizio `SSH` sul firewall `F2` 
```console
# Abilitare ssh in F2 (parte 2)
iptables -A INPUT -p tcp -i eth0 --dport 22 -j ACCEPT 
iptables -A OUTPUT -p tcp -o eth0 --sport 22 -j ACCEPT 
```

- Creiamo le sottocatene da agganciare a `FORWARD`
```console
iptables -N greenAll
iptables -N allGreen
iptables -N DMZred
iptables -N redDMZ
```

- Agganciamo le catene a quella di `FORWARD`
```console
iptables -A FORWARD -s 10.0.6.0/24 -i eth0 -o eth1 -j greenAll
iptables -A FORWARD -d 10.0.6.0/24 -i eth1 -o eth0 -j allGreen
iptables -A FORWARD -i eth0 -o eth1 -s 10.0.4.0/23 -d 10.0.0.0/22 -j DMZred
iptables -A FORWARD -o eth0 -i eth1 -d 10.0.4.0/23 -s 10.0.0.0/22 -j redDMZ
```

- Applichiamo le regole con le giuste policy di `ACCEPT`
```console
iptables -A greenAll -j ACCEPT
iptables -A allGreen -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A DMZred -j ACCEPT
iptables -A redDMZ -m state --state ESTABLISHED,RELATED -j ACCEPT
```

- Abilitiamo le `echo-request` da parte di `RED->DMZ` e le `echo-reply` da `DMZ->RED`
```console
# Abilitare nuove richieste (echo-request | 8) ICMP da RED verso DMZ
iptables -A redDMZ -p icmp --icmp-type 8 -j ACCEPT

# Abilitare le risposte (echo-reply | 0) ICMP da DMZ  verso RED
iptables -A DMZred -p icmp --icmp-type 0 -j ACCEPT
```

- Salviamo il file (`CTRL+O`) e chiudiamolo (`CTRL+X`)
- Avviamo lo script del firewall con `sh /etc/network/firewall.sh`
- Per renderlo eseguibile automaticamente all'avvio, aggiungere in fondo al file `/etc/network/interfaces` la riga
```console
 post-up sh /etc/network/firewall.sh
```


## Testing del firewall
Per provare la configurazione del firewall, è possibile eseguire richieste ping da un'area ad un'altra e verificare all'interno del firewall lo stato attuale dei pacchetti accettati e dorppati, tramite il comando 
```console
watch iptables -nvL
```
- **Hint:** è possibile sostituire all'interno della topologia qualche `VPCS` con host `linux (ubuntu_mini)` così da avere la possibilità di installare applicativi quali, ad esempio, `apache2` e `openssh-server` e aprire nuovi socket server su diverse porte da poter testare tramite il firewall appena creato
