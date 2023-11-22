# Subnetting - Topologia Progetto

## Prerequisiti
- `GNS3`
- `QEMU VMs` 
- `Wireshark` 

## Obiettivo
- Suddividere la topologia del progetto ed accorpare eventuali sotto-reti in una unica rete 

## Disclaimer
In questa guida faremo riferimento alle maschere di rete (`netmask`) ordinandole in ordine numerico crescente. Sempre in questa guida, quando si parla di *maschera più piccola*, si fa riferimento alla maschera di rete con il valore numerico più basso (e.g., 22 < 23 < 24). Tuttavia, si da per assunto che lo studente sia a conoscenza del fatto che una maschera 22 metta a disposizione un numero di indirizzi ip maggiore rispetto ad una maschera 23 e così via.

## Topologia della rete
![alt text](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Subnetting/project_topology.png?raw=true)

## Suddivisione della topologia - Subnetting 
### Step 1
Individuare per ogni dominio di collisione `CDn`, l'area di appartenenza
```console
  CD1 -> Area GREEN
  CD6 e CD7 -> Area RED
  CD8 e CD9 -> Area DMZ
  CD2, CD4 e CD5 -> NA (Not Assigned)
```
### Step 2
Assegnare una maschera ad ogni dominio di collisione.
**Attenzione:** in questa fase non importa l'ordine in cui prendiamo in considerazione i domini di collisione

- Esaminiamo il primo dominio di collisione, e.g., `CD1` e osserviamo il valore `minIP`, ovvero il numero di indirizzi ip richiesti per un determinato dominio di collisione
- Assegnamo una maschera di rete che soddisfi il valore `minIP` e che sia la più piccola possibile
- Risolviamo la seguente disequazione `(2^x - 2) >= minIP` e otteniamo il valore `x` che rappresenta il numero di bit da assegnare alla sotto-rete

$CD1:$
$minIP = 133$ 
$( 2^x -2)>=133$
$x=8$
$Mask(CD1)=32-8=24$

- Proseguiamo così per tutti gli altri domini di collisione
```
  # GREEN
  CD1: 133 -> Mask(CD1) = 24

  # NA - I domini NA, sono quelli point-to-point e
  # quindi richiedono solo 2 indirizzi ip
  CD2: 2 -> Mask(CD2) = 30
  CD4: 2 -> Mask(CD4) = 30
  CD5: 2 -> Mask(CD5) = 30

  # È un dominio di collisione speciale che ci servirà
  # per collegare la topologia alla rete internet
  CDTAP: 2 -> Mask(CDTAP) = 30
  
  # RED
  CD6: 176 -> Mask(CD6) = 24
  CD7: 363 -> Mask(CD7) = 23
  
  # DMZ
  CD8: 239 -> Mask(CD8) = 24
  CD9: 105 -> Mask(CD9) = 25
```

### Step 3
Accorpare eventuali sotto-reti in una unica rete

- Ordiniamo, per ogni area, le maschere di rete in ordine crescente accorpando, gradualmente le sottoreti

```
AREA RED
  CD7: 23
  CD6: 24

AREA GREEN
  CD1: 24

AREA DMZ
  CD8: 24
  CD9: 25
```

- Calcoliamo la maschera **totale** della rete accorpata, ovvero dell'area
  - Se l'area contiene al suo interno soltanto 2 domini di collisione, allora la maschera totale è uguale alla maschera del dominio di collisione più piccolo - 1
  Esempio:
  ```
    AREA RED
      CD7: 23
      CD6: 24
  ```
  $Mask(RED)=min(23,24)-1$
  $Mask(RED)=22$
  - Se l'area contiene al suo interno più di 2 domini di collisione, allora la maschera totale andrà calcolata come segue:
    - Disegniamo l'albero delle maschere di rete e saliamo fino alla radice
    Esempio - Supponiamo di avere l'area `BLACK` contenente al suo interno i seguent `CD`
    ```
    AREA BLACK
      CD101: 24
      CD102: 24
      CD103: 25
      CD104: 27
    ```
![alt text](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Subnetting/example_tree.png?raw=true)
```
  Mask(BLACK) = 22
```

- Nella nostra topologia, le aree avranno le seguenti maschere di rete
```
  Mask(AREA RED) = 22
  Mask(AREA GREEN) = 24
  Mask(AREA DMZ) = 23
```

### Step 4
A questo punto riscriviamo tutte le maschere di aree e dei domini di collisione ordinatamente in ordine crescente

```
AREA RED: 22
  CD7: 23
  CD6: 24

AREA DMZ: 23
  CD8: 24
  CD9: 25

AREA GREEN: 24
  CD1: 24
```
**Nota Bene:** Le aree sono ordinate in ordine crescente di maschera (dalla 22 alla 24) e contemporaneamente, anche i domini di collisione al loro interno sono ordinata in ordine crescente di maschera


### Step 5
A questo punto, procediamo con il calcolo dell'indirizzo di rete e del broadcst per ogni dominio di collisione

- Partiamo dal primo dominio di collisione della prima area, nel nostro caso, `CD7` dell'area `RED`

- Asegniamo il `network`

  - **N.B.:** Il primo indirizzo di network per una `classe di tipo A` è `10.0.0.0`

```console
  CD7
  Network: 10.0.0.0/23
  Netmask 23
```
- Convertiamo la `netmask` in formato IP

```console
  # Maschera 23 = i primi 23 bit impostati ad 1 ed i
  # restanti 9 a 0, poi effettuiamo la conversione da
  # binario a decimale per ogni blocco di bit

  11111111.11111111.11111110.00000000
  --------.--------.--------.--------
    255   .  255   .   254  .    0
```

```console
  CD7
  Network: 10.0.0.0/23
  Netmask: 255.255.254.0
```

- Calcoliamo il `broadcast`
  - Trasformiamo l'indirizzo di rete (`network`) in formato binario
  
  ```console
    10.0.0.0 -> 00001010.00000000.00000000.00000000
  ```
  - Invertiamo i bit della `netmask`
    
    ```console
      Netmask:
      11111111.11111111.11111110.00000000
      
      # Netmask invertendo i bit
      00000000.00000000.00000001.11111111
    ```
  
  - Svolgiamo l'`OR logico` tra il `network` e la `netmask invertita`
  
  ```console
    00001010.00000000.00000000.00000000
    00000000.00000000.00000001.11111111
    -----------------------------------
    00001010.00000000.00000001.11111111
  ```

  - Convertiamo il risultato in decimale

  ```console
    00001010.00000000.00000001.11111111
    --------.--------.--------.--------
      10   .   0    .   1    .   255
  ```

- Ricapitolando, abbiamo ottenuto i seguenti valori per il dominio di collisione `CD7`

  ```console
    CD7
    Network: 10.0.0.0/23
    Netmask: 255.255.254.0
    Broadcast: 10.0.1.255
  ```

- Proseguiamo con la suddivisione di tutti gli altri domini di collisione contenuti all'interno della stessa area di `CD7`, ovvero dell'area `RED`

- Assegnare il `network` al dominio di collisione `CD6`
  - Il `network` del dominio di collisione successivo al primo, sarà assegnato prendendo l'indirizzo IP del `broadcast` del dominio di collisione precedente e incrementandolo di 1 bit

```console
  CD6 --> Network = broadcast(CD7) + 1
  Network: 10.0.2.0
```
- Convertiamo la netmask di `CD6` in formato IP seguendo gli stessi step mostrati in precedenza

```console
  CD6
  Network: 10.0.2.0/24
  Netmask: 255.255.255.0
```

- Calcoliamo il `broadcast` di `CD6` ripetendo gli stessi step effettuati in precedenza, ottenendo quindi

```console
  CD6
  Network: 10.0.2.0/24
  Netmask: 255.255.255.0
  Broadcast: 10.0.2.255
```

### Step 6
Una volta suddivisi **TUTTI** i domini di collisione contenuti all'interno della **STESSA** area, procediamo con il calcolo dell'indirizzo di rete e del broadcast dell'area stessa

- Assegnamo il `network` all'area
  - Il `network` dell'area sarà uguale all'indirizzo IP del `network` del dominio di collisione con maschera più piccola

```console
  Network(AREA RED) = network(CD7)
  Network(AREA RED) = 10.0.0.0
```

- Da qui in poi si procede con la conversione della `netmask` e successivo calcolo del `broadcast` come visto nello **Step 5**

```console
  AREA RED
  Network: 10.0.0.0/22
  Netmask: 255.255.252.0
  Broadcast: 10.0.3.255
```

### Step 7
- Da ora è possibile passare alla suddivisione dei domini di collisione contenuti all'interno della **SECONDA** area, ovvero l'area `DMZ`

- Gli step da seguire sono identici a quelli visti in precedenza con l'unica differenza che, quando si passa dal suddividere un dominio di collisione di un'area diversa da quella precedente, il `network` dovrà essere calcolato nel seguente modo:
  
  ```console
    Network(Dominio di collisione) = broadcast(AREA precedente) + 1
  ```
  - In questo caso, il `network` del dominio di collisione `CD8` sarà uguale al `broadcast` dell'area `RED` + 1

  ```console
    CD8 --> Network = broadcast(AREA RED) + 1
    Network: 10.0.4.0
  ```