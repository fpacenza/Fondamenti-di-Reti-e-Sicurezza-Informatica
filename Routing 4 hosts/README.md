# Esercitazione 1 - Routing con 4 hosts

## Prerequisiti
- `GNS3`
- `QEMU VMs` 
- `Wireshark` 

## Obiettivo
- Configurare un laboratorio in grado di effettuare il routing dei pacchetti dall'host `PC1` all'host `PC2` passando per i router `F1` ed `F2`

## Topologia della rete
![alt text](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Routing%204%20hosts/routing_4_hosts.png?raw=true)

## Configurazione della topologia
- Dalla schermata dei dispositivi sulla sinistra, trascinare nell'editor di GNS3
  - **2 VPCS** (`PC1` e `PC2`)
  - **2 VMs qemu** (`F1` ed `F2`)
  - **3 switch** `Ethernet switch` (`CD1`, `CD2` e `CD3`)
  - Connessioni tra i dispositivi come mostrato nella topologia
    - **Attenzione:** verifica attentamente come sono connesse nella topologia le interfacce di rete `eth0`, `eth1`, etc al fine di evitare errori di configurazione dei dispositivi!!!
  - Una volta collegati tutti i dispositivi come in figura, avvia il laboratorio cliccando sul tasto `Start` di GNS3

## Configurazione dei dispositivi
### PC1
- **NETWORK:** `10.0.0.0`
- **MASK:** `255.255.255.0`
- **IP:** `10.0.0.2`
- **BROADCAST:** `10.0.0.255`
- **GW:** `10.0.0.1`

#### Configrazione tramite GNS3
- Tasto destro del mouse su `PC1`
- Selezionare `edit config`
- Inserire la seguente riga:
 `ip 10.0.0.2 255.255.255.0 10.0.0.1`
- Cliccare su `Save`
- Tasto destro del mouse su `PC1`
- Selezionare `Reload`


### PC2
- **NETWORK:** `10.0.1.0`
- **MASK:** `255.255.255.0`
- **IP:** `10.0.1.2`
- **BROADCAST:** `10.0.1.255`
- **GW:** `10.0.1.1`

#### Configrazione tramite GNS3
- Tasto destro del mouse su `PC2`
- Selezionare `edit config`
- Inserire la seguente riga:
 `ip 10.0.1.2 255.255.255.0 10.0.1.1`
- Cliccare su `Save`
- Tasto destro del mouse su `PC2`
- Selezionare `Reload`


### F1
- **eth0**
  - **NETWORK:** `10.0.2.0`
  - **MASK:** `255.255.255.252`
  - **IP:** `10.0.2.1`
  - **BROADCAST:** `10.0.2.3`
- **eth1**
  - **NETWORK:** `10.0.0.0`
  - **MASK:** `255.255.255.0`
  - **IP:** `10.0.0.1`
  - **BROADCAST:** `10.0.0.255`

#### Configrazione tramite terminale della VM
- Aprire il file `/etc/network/interfaces` usando `pico` o `nano` e configurare le interfacce come segue:

      auto eth0
      iface eth0 inet static
        network 10.0.2.0
        netmask 255.255.255.252
        address 10.0.2.1
        broadcast 10.0.2.3

      auto eth1
      iface eth1 inet static
        network 10.0.0.0
        netmask 255.255.255.0
        address 10.0.0.1
        broadcast 10.0.0.255

- Salvare il file ed uscire dall'editor con `CTRL+X`
- Riavviare il servizio di networking con il comando `service networking restart` 
- **Attenzione:** attivare su tutti i router/firewall l'opzione di ip forwarding con il comando `sysctl -w net.ipv4.ip_forward=1`

### F2
- **eth0**
  - **NETWORK:** `10.0.2.0`
  - **MASK:** `255.255.255.252`
  - **IP:** `10.0.2.2`
  - **BROADCAST:** `10.0.2.3`
- **eth1**
  - **NETWORK:** `10.0.1.0`
  - **MASK:** `255.255.255.0`
  - **IP:** `10.0.1.1`
  - **BROADCAST:** `10.0.1.255`

#### Configrazione tramite terminale della VM
- Aprire il file `/etc/network/interfaces` usando `pico` o `nano` e configurare le interfacce come segue:

      auto eth0
      iface eth0 inet static
        network 10.0.2.0
        netmask 255.255.255.252
        address 10.0.2.2
        broadcast 10.0.2.3

      auto eth1
      iface eth1 inet static
        network 10.0.1.0
        netmask 255.255.255.0
        address 10.0.1.1
        broadcast 10.0.1.255

- Salvare il file ed uscire dall'editor con `CTRL+X`
- Riavviare il servizio di networking con il comando `service networking restart`
- **Attenzione:** attivare su tutti i router/firewall l'opzione di ip forwarding con il comando `sysctl -w net.ipv4.ip_forward=1`

## Verifica della configurazione
- Aprire il terminale di `PC1` e digitare il comando `ping 10.0.1.2`
- Verifica il percorso dei pacchetti usando `Wireshark` direttamente tramite GNS3
  - Tasto destro del mouse sul link che connette `F1` a `CD3`
  - Cliccare su `start capture`
  - Analizzare il traffico di rete sul link `eth0` di `F1`
  - Ripeti questi step sugli altri link per avere più dettagli a livello di ogni singolo link


