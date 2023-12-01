# Connessione SSH e Backup - Topologia Progetto

## Prerequisiti
- Aver completato l'esercitazione [Internet e TAP](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/tree/main/Internet%20e%20TAP)

## Obiettivo
- Installare un server `ssh` sui router e sui firewall
- Connettersi dal computer locale alle `VMs` tramite `ssh`
- Eseguire il backup dei file di configurazione tramite `ssh` ed `sshfs`
- 
## Topologia della rete
![alt text](https://github.com/fpacenza/Fondamenti-di-Reti-e-Sicurezza-Informatica/blob/main/Routing/project_topology_gns3.png?raw=true)


## Installazione del server SSH
- Installare il server SSH sulle macchine virtuali Linux (`ubuntu_mini`) presenti nella nostra topologia (`F1`, `F2`, `R1` ed `R2`)
```console
apt install -y openssh-server
```

## Configurazione SSH sulle macchine virtuali Linux
Tutti i Firewall e i Router all'interno della nostra topologia devono essere abilitati al fine di consentire le connessioni ssh dall'esterno della rete. Per fare ciò è necessario modificare il file di configurazione `ssh` che si trova al seguente path `/etc/ssh/sshd_config`

**ATTENZIONE:** questo step deve essere ripetuto per ogni macchina virtuale Linux (`ubuntu_mini`) presente nella nostra topologia (`F1`, `F2`, `R1` ed `R2`)
- Aprire il terminale di una delle macchine interessate alla modifica e digitare 
```console
pico /etc/ssh/sshd_config
```

- Cercare le seguenti righe e modificarle come segue
```console
#PermitRootLogin prohibit-password
PermitRootLogin yes

...

#PasswordAuthentication yes
PasswordAuthentication yes
```
- La riga `PermitRootLogin` deve essere decommentata (rimuovere il `#` all'inizio) e modificata in modo tale che il valore sia `yes` e non `prohibit-password`
- La riga `PasswordAuthentication` deve essere decommentata (rimuovere il `#` all'inizio) e deve contenere il valore `yes`

- Salvare le modifiche (`CTRL+O`)
- Chiudere l'editor di testo (`CTRL+X`)
- Riavviare il servizio `ssh` con il comando `service ssh restart` oppure `systemctl restart ssh`

## Test della connessione SSH
- Aprire il terminale del vostro computer locale e digitare il seguente comando
```console
ssh root@10.0.7.14
```
- Digitare `YES` se compare un messaggio di verifica della chiave RSA
- Inserire la password `root` quando richiesto
- Se la connessione è andata a buon fine, il terminale del vostro computer locale sarà connesso al terminale della macchina virtuale Linux (`ubuntu_mini`) `F1`
- Effettuare la stessa verifica su tutte le macchine virtuali Linux (`ubuntu_mini`) presenti nella nostra topologia (`F1`, `F2`, `R1` ed `R2`)


## Eseguire il backup del progetto
A questo punto, siamo pronti per poter effettuare il backup del nostro progetto **GNS3**

- Aprire il terminale del vostro computer locale e digitare il seguente comando utile ad installare il tool `sshfs`
```console
sudo apt install sshfs
```
- Creare una cartella sul vostro computer locale dove verrà montata la cartella remota del server SSH

```console
cd /home/$USER/Scrivania/
mkdir backup_progetto_reti
```

- Creare all'interno della cartella precedentemente creata, una cartella per ogni macchina virtuale Linux (`ubuntu_mini`) presente nella nostra topologia (`F1`, `F2`, `R1` ed `R2`)
```console
cd backup_progetto_reti
mkdir F1 R1 F2 R2
```

- Montare le **cartella remote** del server SSH `F1`, `R1`, `F2` e `R2` all'interno delle **cartelle locali** `F1`, `R1`, `F2` e `R2` avendo cura di eseguire i comandi **uno alla volta** e di digitare la password `root` quando richiesto
```console
sshfs root@10.0.7.14:/ /home/$USER/Scrivania/backup_progetto_reti/F1
sshfs root@10.0.7.2:/ /home/$USER/Scrivania/backup_progetto_reti/R1
sshfs root@10.0.7.6:/ /home/$USER/Scrivania/backup_progetto_reti/F2
sshfs root@10.0.7.10:/ /home/$USER/Scrivania/backup_progetto_reti/R2
```

- Aprite la cartella `backup_progetto_reti` presente sul vostro computer locale e verificate che siano presenti le cartelle `F1`, `R1`, `F2` e `R2` contenenti i file di configurazione delle macchine virtuali Linux (`ubuntu_mini`) `F1`, `R1`, `F2` e `R2` presenti nella nostra topologia

- Copiate i file che si trovano nella cartella `backup_progetto_reti/*NOME_HOST*/etc/network/interfaces` di ogni macchina virtuale Linux (`ubuntu_mini`) presente nella nostra topologia (`F1`, `F2`, `R1` ed `R2`) all'interno della cartella `backup_progetto_reti` presente sul vostro computer locale (Sostituite \*NOME_HOST\*) con il nome della macchina virtuale Linux di riferimento

- Potete effettuare il backup di qualsiasi file creato all'interno delle macchine virtuali anche successivamente ripetendo questa guida passo passo (utile per salvare la configurazione del firewall `iptables`)

## Smontare il filesystem del server SSH
- Ricordatevi di **smontare** il file system delle macchine virtuali usando il comando
```console
fusermount -uz /home/$USER/Scrivania/backup_progetto_reti/F1
fusermount -uz /home/$USER/Scrivania/backup_progetto_reti/R1
fusermount -uz /home/$USER/Scrivania/backup_progetto_reti/F2
fusermount -uz /home/$USER/Scrivania/backup_progetto_reti/R2
```
- A questo punto, le **cartelle locali** `F1`, `F2`, `R1` e `R2` saranno vuote (ed è corretto così!) 
