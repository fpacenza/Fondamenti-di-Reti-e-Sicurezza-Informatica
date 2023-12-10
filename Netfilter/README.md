# Netfilter - Concetti Base

## Prerequisiti
- Aver completato l'esercitazione [Internet e TAP](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/tree/main/Internet%20e%20TAP)

## Obiettivo
### Apprendere i concetti base di `iptables` e saper configurare un firewall `linux` con `iptables` per una rete locale
- [x] Introduzione a `netfilter`
- [x] Tabelle - `filter`, `nat`, `mangle`, `raw`
- [x] Catene - `INPUT`, `OUTPUT`, `FORWARD`, `PREROUTING`, `POSTROUTING`
- [x] Policy di default
- [x] Regole - `filtri` e `targets`

## Introduzione a `Netfilter`
`Netfilter` è il componente del **kernel Linux** che permette l’intercettazione e la manipolazione di pacchetti.

È molto utilizzato per via delle sue funzionalità avanzate quali, ad esempio, il `filtraggio stateful` del traffico di rete e il `NAT` (o `natting`).

È un modulo estendibile, che permette di aggiungere nuove funzionalità tramite l’uso di `moduli kernel` che consentono di implementare nuove funzionalità di `inspection` e `manipolazione` dei pacchetti.

È gestibile tramite i comandi `iptables` (per IPv4) e `ip6tables` (per IPv6).

## Tabelle di `Netfilter`

Il funzionamento di netfilter è incentrato sull’utilizzo di tabelleche sono implementate a `livello kernel`.
Netfilter ha 4 tabelle:

- `filter:` consente il **filtraggio dei pacchetti**. Permette di scegliere quali bloccare e quali far passare.
- `nat:` permette di instradare i pacchetti verso diversi host su reti **NAT (Network Address Translation)** cambiando l’indirizzo di origine e di destinazione dei pacchetti. Viene spesso utilizzato per consentire l’accesso a servizi a cui non è possibile accedere direttamente, perché sono su una rete NAT.
- `mangle:` permette di **modificare le intestazioni** dei pacchetti in vari modi, come ad esempio cambiando i valori TTL.
- `raw:` permette di lavorare con i pacchetti prima che il kernel inizi a tracciare il suo stato. Inoltre, è anche possibile esonerare alcuni pacchetti dal monitoraggio dello stato.

## Catene di iptables
Ognuna di queste tabelle è composta da alcune catene predefinite. Queste catene permettono di filtrare i pacchetti in vari punti. L’elenco delle catene che iptables fornisce sono:

- **PREROUTING:** le regole di questa catena si applicano ai pacchetti appena arrivati sull’interfaccia di rete. Questa catena è presente nelle tabelle **nat**, **mangle** e **raw**.
- **INPUT** le regole di questa catena si applicano ai pacchetti appena prima di essere dati a un processo locale - **dati in ingresso sull'host corrente**. Questa catena è presente nelle tabelle **mangle** e **filter**.
- **OUTPUT** le regole qui si applicano ai pacchetti subito dopo che sono stati prodotti da un processo - **dati in uscita sull'host corrente**. Questa catena è presente nelle tavole **raw**, **mangle**, **nat** e **filter**.
- **FORWARD** le regole qui si applicano a qualsiasi pacchetto che viene **instradato attraverso l’host corrente**. Questa catena è presente solo nelle tabelle **mangle** e **filter**.
- **POSTROUTING** le regole di questa catena si applicano ai pacchetti in quanto lasciano semplicemente l’interfaccia di rete. Questa catena è presente nelle tabelle **nat** e **mangle**.

## Policy di default
Ogni catene ha una policy, cioè un'azione predefinita da eseguire quando tutti gli altri controlli della catena hanno fallito nel riconoscere se il dato era buono o meno. Si può optare per una policy di default più permissiva (`ACCEPT`) o più restrittiva (`DROP`), a seconda delle esigenze.



## Regole di iptables
Ogni catena iptables è composta da un insieme di `regole di filtraggio`, che vengono applicate in sequenza a ogni pacchetto di rete che passa attraverso la catena.

### Filtri
Le regole iptables sono composte da una serie di `criteri di filtraggio`, come l’indirizzo **IP sorgente** e **destinazione**, il **protocollo** di rete, il **numero di porta**, lo **stato del pacchetto** e altre caratteristiche dei pacchetti di rete.

Le regole di iptables sono **organizzate in modo gerarchico**, in cui le regole più specifiche hanno la precedenza su quelle più generiche. In questo modo, è possibile creare politiche di filtraggio del traffico di rete personalizzate e granulari, in base alle esigenze specifiche della rete e dell’applicazione.

### Targets
I target rappresentano l’azione che deve essere eseguita sui pacchetti di rete che corrispondono ad una determinata regola di filtraggio. I target di iptables possono essere di due tipi:

- **ACCEPT:** lascia passare il pacchetto

- **DROP:** scarta il pacchetto, senza inviare alcuna risposta al mittente 

- **REJECT:** scarta il pacchetto, inviando una risposta `ICMP` **Internet Control Message Protocol** al mittente, per indicare che il pacchetto è stato bloccato dal firewall

- **QUEUE:** mette il pacchetto in una coda, che può essere dedicata a una specifica applicazione

- **RETURN:** ha lo stesso effetto di raggiungere la fine di una chain, agisce ricorsivamente come una chiamata a funzione

- **LOG:** registra informazioni sul pacchetto di rete in un file di log del sistema

- **DNAT:** esegue il Destination NAT - modifica l’indirizzo IP di destinazione del pacchetto di rete

- **SNAT:** esegue il Source NAT - modifica l’indirizzo IP sorgente del pacchetto di rete

- **MASQUERADE:** utilizzato nella tabella nat, consente di nascondere l’indirizzo IP sorgente del pacchetto di rete, sostituendolo con l’indirizzo IP dell’interfaccia di rete del firewall

La scelta del target dipende dalle esigenze specifiche della rete e dell’applicazione. Ad esempio, si può scegliere di scartare i pacchetti di rete provenienti da un determinato indirizzo IP, utilizzando il target `DROP`. Al contrario, si può scegliere di permettere il passaggio di determinati pacchetti di rete, utilizzando il target `ACCEPT`.
