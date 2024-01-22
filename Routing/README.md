# Routing - Topologia Progetto

## Prerequisiti
- Aver completato l'esercitazione [Subnetting Laboratorio](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/tree/main/Subnetting)

## Obiettivo
- Configurare la topologia di rete mostrata nella precedente esercitazione di subnetting utilizzando il software GNS3
- Configurare i router in modo tale che sia possibile effettuare il routing tra le varie aree della rete

## Topologia della rete
![alt text](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Subnetting/project_topology.png?raw=true)


## Creazione della topologia in GNS3 
- Avviamo il software GNS3
- Creaiamo un nuovo progetto cliccando su `File -> new blank project`
- Inseriamo il nome che preferiamo per il progetto e clicchiamo su `OK`
- Sulla menù a sinistra clicchiamo su `Browse all devices` <img src="https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Routing/browse_all_devices.png?raw=true" width="25">
- Per ogni dominio di collisione $CD_n$ presente nella nostra topologia, trasciniamo un `Ethernet Switch` all'interno del laboratorio GNS3
- Per ogni host $PC_n$, $S_n$ oppure $Snatted_n$ presente nella nostra topologia, trasciniamo una `VPCS` all'interno del laboratorio GNS3
- Per ogni firewall $F_n$ e router $R_n$ presente nella nostra topologia, trasciniamo una macchina virtuale `qemu` che all'interno del laboratorio GNS3 si chiamerà `linux` (o con il nome che avete scelto in fase di configurazione)
- Collegate tramite `link` i dispositivi trascinati all'interno del laboratorio GNS3 usando l'apposito tasto presente nel menù a sinistra <img src="https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Routing/link.png?raw=true" width="25">
- Rinominate appropriatamente i dispositivi trascinati all'interno del laboratorio GNS3 fino ad ottenere la seguente topologia

![alt text](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Routing/project_topology_gns3.png?raw=true)

## Configurazione degli host
1. Avviamo il laboratorio GNS3
2. Attendiamo l'avvio di tutte le macchine virtuali
3. Assegniamo ad ogni host un indirizzo ip all'interno del suo network e della sua maschera di rete
4. Configuriamo leschede di rete di tutti i `VPCS`
5. Configuriamo per ogni firewall e router tutte le schede di rete utilizzate

**Attenzione:** per gli step 4 e 5 fare riferimento alla guida [Routing 4 hosts](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/tree/main/Routing%204%20hosts)

## Configurazione delle tabelle di routing
A questo punto, procediamo con la configurazione delle tabelle di routing per ogni `firewall` e `router` presente nella nostra topologia

### Firewall
Nella nostra topologia, i firewall sono 2 e si comportano anche da router, di conseguenza, la loro tabella di routing deve essere aggiornata specificando le rotte per ogni area della rete

#### Firewall 1
- Eseguiamo il comando `route -n` e notiamo che la tabella di routing contiene solo le rotte delle reti direttamente connesse `point-to-point`
- Il firewall `F1` deve essere in grado di comunicare con tutte le reti presenti nella topologia, di conseguenza, dobbiamo aggiungere le rotte per ogni area della rete
- Le rotte mancanti in `F1` sono quelle dirette verso `CD4`, `CD5`, `Area DMZ` e `Area RED`
- Per aggiungere una rotta, eseguiamo il comando `route add -net <network> netmask <mask> gw <gateway> dev <device>`
**N.B.:** Se aggiungiamo una rotta da terminale, al riavvio della macchina virtuale, la rotta non sarà presente
- Se vogliamo aggiungere una rotta e installarla automaticamente al riavvio delle macchine virtuali, dobbiamo aggiungere la rotta nel file `/etc/network/interfaces` usando il comando `post-up route add -net <network> netmask <mask> gw <gateway> dev <device>`
- Aggiungiamo le seguenti rotte alla fine del file `/etc/network/interfaces` di `F1`:
```console
...

# Rotta di default per andare verso Internet
post-up route add default gw 10.0.7.13 dev eth0

# Rotta per raggiungere CD4
post-up route add -net 10.0.7.4/30 gw 10.0.7.2 dev eth2

# Rotta per raggiungere CD5
post-up route add -net 10.0.7.8/30 gw 10.0.7.2 dev eth2

# Rotta per raggiungere Area DMZ
post-up route add -net 10.0.4.0/23 gw 10.0.7.2 dev eth2

# Rotta per raggiungere Area RED
post-up route add -net 10.0.0.0/22 gw 10.0.7.2 dev eth2
```

- Eseguiamo il comando `service networking restart` per riavviare il servizio di rete e rendere effettive le modifiche apportate al file `/etc/network/interfaces`
- Controlliamo che le rotte siano state inserite nella tabella di routinh eseguendo il comando `route -n`

#### Firewall 2
- Ripetiamo gli step svolti per `F1` anche per `F2` sostituendo in modo appropriato le rotte
- Le rotte mancanti in `F2` sono quelle dirette verso `Area GREEN`, `Area DMZ`, `Area RED` e `CD2`
- Aggiungiamo le seguenti rotte alla fine del file `/etc/network/interfaces` di `F2`:
- Notare che in questo caso, con una sola rotta di default riusciamo a coprire i percorsi dei pacchetti che vanno sia verso `Internet` che verso le aree `GREEN`, `DMZ` e verso `CD2`
```console
...

# Rotta di default per andare verso Internet
# Rotta per raggiungere Area GREEN
# Rotta per raggiungere Area DMZ
# Rotta per raggiungere CD2
post-up route add default gw 10.0.7.5 dev eth0

# Rotta per raggiungere Area RED
post-up route add -net 10.0.0.0/22 gw 10.0.7.10 dev eth1
```

- Eseguiamo il comando `service networking restart` per riavviare il servizio di rete e rendere effettive le modifiche apportate al file `/etc/network/interfaces`
- Controlliamo che le rotte siano state inserite nella tabella di routinh eseguendo il comando `route -n`

#### Rotuer 1
- Le rotte mancanti in `R1` sono quelle dirette verso `Area GREEN`, `Area RED` e `CD5`
- Aggiungiamo le seguenti rotte alla fine del file `/etc/network/interfaces` di `R1`:
```console
...

# Rotta di default per andare verso Internet
# Rotta per raggiungere Area GREEN
post-up route add default gw 10.0.7.1 dev eth3

# Rotta per raggiungere Area RED
post-up route add -net 10.0.0.0/22 gw 10.0.7.6 dev eth0

# Rotta per raggiungere CD5
post-up route add -net 10.0.7.8/302 gw 10.0.7.6 dev eth0
```

- Eseguiamo il comando `service networking restart` per riavviare il servizio di rete e rendere effettive le modifiche apportate al file `/etc/network/interfaces`
- Controlliamo che le rotte siano state inserite nella tabella di routinh eseguendo il comando `route -n`

#### Rotuer 2
- Le rotte mancanti in `R3` sono quelle dirette verso `Area GREEN`, `Area DMZ`, `CD2`, `CD4`
- Aggiungiamo le seguenti rotte alla fine del file `/etc/network/interfaces` di `R3`:
- Notare che in questo caso, con una sola rotta di default riusciamo a coprire tutti i percorsi dei pacchetti che vanno sia verso `Internet` che verso le aree `GREEN`, `DMZ` e verso `CD2` e `CD4`
```console
...

# Rotta di default per andare verso Internet
# Rotta per raggiungere Area GREEN
# Rotta per raggiungere Area DMZ
# Rotta per raggiungere CD2
# Rotta per raggiungere CD4
post-up route add default gw 10.0.7.9 dev eth0
```

- Eseguiamo il comando `service networking restart` per riavviare il servizio di rete e rendere effettive le modifiche apportate al file `/etc/network/interfaces`
- Controlliamo che le rotte siano state inserite nella tabella di routinh eseguendo il comando `route -n`

## Controllo della connettività di rete
A questo punto, la configurazione della topologia è terminata e possiamo procedere con il controllo della connettività di rete

- Apriamo la console del computer `PC1` e verifichiamo che sia possibile effettuare il ping verso tutti gli altri host della rete
- Ripetiamo il controllo della connettività di rete per tutti gli altri host della rete

## Cosa fare se le richieste di ping non vanno a buon fine?
1. Esaminiamo il messaggio di errore ottenuto (si tratta di timeout, di host unreachable, di network unreachable, ecc...)
2. Verifichiamo che le tabelle di routing di tutti i dispositivi siano state configurate correttamente
3. Verifichiamo che le schede di rete di tutti i dispositivi siano state configurate correttamente
4. Avviamo una cattura `Wireshark` sui vari link della rete e 
    4.1. Verifichiamo se i pacchetti ICMP `echo-request` sono correttamente inoltrati verso la destinazione
        - Se le `echo-request` non sono correttamente inoltrate verso la destinazione controlliamo dove vengono persi e cerchiamo di capirne il motivo
        - Altrimenti, passiamo allo step 4.2
    4.2. Verifichiamo se i pacchetti di risposta `echo-reply` vengono generati e dove è che si fermano cercando di capirne il motivo 
5. Verifichiamo che il firewall sia completamente disattivato (non sono presenti regole di firewalling e/o la politica di default è impostata a `ACCEPT`)
