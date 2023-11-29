# Internet e TAP - Topologia Progetto

## Prerequisiti
- Aver completato l'esercitazione [Routing Laboratorio](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/tree/main/Routing)

## Obiettivo
- Configurare la connettività Internet del laboratorio **GNS3** tramite l'uso di una interfaccia di rete virtuale di tipo **TAP**

## Topologia della rete
![alt text](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Routing/project_topology_gns3.png?raw=true)


## Configurazione Interfaccia di rete TAP
l'**Internet Tap**, o seplicemente **TAP** è un dispositivo hardware o software inserito in reti informatiche che ci consente di monitorare attivamente in maniera non invasiva il flusso dati in transito. Il significato del nome in lingua inglese è rubinetto, e rappresenta in modo figurato lo scopo del dispositivo.
Nella nostra topologia, useremo una interfaccia di rete virtuale da nome **tap0** per simulare la connessione ad internet. Per creare e configurare l'interfaccia di rete **tap0** all'interno del nostro computer e all'interno di **GNS3** seguire i seguenti passaggi

### Step 1: Creazione interfaccia di rete virtuale
**Attenzione:** Tutti i comandi che seguono devono essere eseguiti all'interno del terminale del vostro computer locale e **NON** all'interno di **GNS3**

- Installare il pacchetto **uml-utilities** con il seguente comando
```console
sudo apt install uml-utilities
```

- Autenticarsi come amministarore con la password di root
```bash
sudo su
```

- Aprire il terminale e digitare i seguenti comandi
```bash
# Crea interfaccia di rete tap0
tunctl -g netdev -t tap0

# Configura l'interfaccia di rete tap0
ifconfig tap0 10.0.7.13
ifconfig tap0 netmask 255.255.255.252
ifconfig tap0 broadcast 10.0.3.15
ifconfig tap0 up
```

- Verificare che l'interfaccia di rete **tap0** sia stata creata e configurata correttamente
```bash
ifconfig tap0
```

- Crea regole di firewalling in grado di mascherare e rediriare il traffico in uscita e in entrata dall'interfaccia di rete **tap0**
```bash
# Crea le regole di firewalling
# Attenzione: cambiare *wlan0* con il nome della propria scheda di rete attualmente connessa alla rete internet
iptables -t nat -F
iptables -t nat -X
iptables -F
iptables -X
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
iptables -A FORWARD -i tap0 -j ACCEPT
```

- Abilitare il forwarding su host locale 
```bash
sysctl -w net.ipv4.ip_forward=1
```

- Aggiunge le rotte alle varie subnets
```bash
route add -net 10.0.0.0/21 gw 10.0.7.14 dev tap0
```

**ATTENZIONE:** È disponibile [QUI](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Internet%20e%20TAP/tap.sh?raw=true) lo script ``tap.sh`` che esegue tutti i comandi precedenti in modo automatico. Per eseguire lo script, aprire il terminale ed eseguire lo script con il seguente comando.
*Abbi cura di cambiare i parametri relativi all tua scheda di rete e alle rotte della topologia.*
```bash
sudo sh tap.sh
```

### Step 2: Configurazione interfaccia di rete virtuale su GNS3
- Avviare **GNS3** e aprire la topologia di progetto
- **NON** eseguite il laboratorio; tutti gli host devono essere spenti
- Cliccare su `Browse all devices` <img src="https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Routing/browse_all_devices.png?raw=true" width="25">
- Trascinare il dispositivo <img src="https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Internet%20e%20TAP/cloud.png?raw=true"> all'interno della topologia
- Click destro sul dispositivo `Cloud` e selezionare `Configure`
- Recarsi nella scheda `TAP Interfaces` e se non è già presente la scheda di rete `tap0` cliccare su `Add` per aggiungere `tap0`
- L'interfaccia di configurazione dovrà apparire come in figura
![alt text](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Internet%20e%20TAP/cloud_configuration.png?raw=true)
- Cliccare su `OK` per salvare le modifiche
- Cliccare su `Add link` <img src="https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Routing/link.png?raw=true" width="25"> nel menù a sinistra in GNS3 e collegare l'interfaccia `tap0` del dispositivo `Cloud` con l'interfaccia `eth0` del firewall `F1`

### Step 3: Controllo della connessione ad internet
- Avviare la topologia
- Avviare il terminale di un host a scelta nella topologia e verificare che sia possibile effettuare il ping verso **Internet**
```bash
ping -c5 8.8.8.8
```
- L'output atteso è il seguente
```bash
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=32.8 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=117 time=37.6 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=117 time=32.1 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=117 time=37.6 ms
64 bytes from 8.8.8.8: icmp_seq=5 ttl=117 time=31.9 ms

--- 8.8.8.8 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4008ms
rtt min/avg/max/mdev = 31.946/34.427/37.642/2.618 ms                                                
```