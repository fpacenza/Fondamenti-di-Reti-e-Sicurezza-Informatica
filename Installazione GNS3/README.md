# Installazione e Configurazione del Laboratorio GNS3

## Disclaimer
*La seguente guida è stata creata e inizialmente creata e testata da <ins>Giovanni Gualtieri</ins> ed è consultabile a questo [link](https://giovix92.com/#/docs/personal/UNICAL/gns3_qemu)*

## Prerequisiti
- **RAM:** >=8GB
- **CPU:** >=4 cores
- **Virtualizzazione:** 
  - **Windows:** VT-x e/o HyperV abilitato nel BIOS Extra:
  - **Linux:** Supporto KVM, vedi qui
- **Immagine disco:** [Download](https://drive.google.com/drive/u/1/folders/16MRwTC0egDwqElUg4pH0MR370WEmd1ji)

## Installazione del software GNS3
GNS3 può essere installato seguendo gli steps indicati sul sito ufficiale
- [Installare GNS3 su Windows](https://docs.gns3.com/docs/getting-started/installation/windows) 
- [Installare GNS3 su MacOS](https://docs.gns3.com/docs/getting-started/installation/mac)
- [Installare GNS3 su Linux](https://docs.gns3.com/docs/getting-started/installation/linux/)


### Risoluzione dei problemi comuni post-installazione
É possibile fare riferimento all pagine delle FAQ relative a GNS3 presente sul sito del corso di Fondamenti di Reti e Sicurezza Informatica.
- [FAQ GNS3](https://sites.google.com/unical.it/inf-fondamentidiretiesicurezza/faq-gns3?authuser=0)


## Attenzione
É altamente consigliato l'utilizzo di una distribuzione `debian/ubuntu-based`

## Configurazione del software GNS3
 - **Linux:** Controllo del supporto KVM
Aprire un terminale, e digitare `lsmod | grep kvm`

Output atteso:

**CPU Intel:**

        kvm_intel
        kvm
**CPU AMD:**

        kvm_amd
        kvm


- Scarica il file zip contenente l’hard disk virtuale, scompattalo e posizionalo in una cartella a tua scelta
- Avvia GNS3, clicca su `Edit->Preferences`
- Apri la scheda `QEMU`:
- Seleziona **Enable hardware acceleration** e **Require hardware acceleration**
- Apri la scheda `Qemu VMs`, e clicca sul tasto `New`
- Qui dovrai inserire i vari parametri della macchina virtuale:
  - **Nome:** `linux`
  - **Attenzione:** NON selezionare `This is a legacy ASA VM`
  - **Qemu binary:** `qemu-system-x86_64` oppure `qemu-system-x86_64w` - versione `4.2.1+`
  - **RAM:** `256MB` (o superiore)
  - **Console type:** `none`
  - **Disk image:**
    - Seleziona `New image`, e clicca sul tasto `browse`
    - Seleziona il file scaricato in precedenza, e attendi il suo caricamento
    - **Nota:** Sii paziente, potrebbe volerci un po’ per caricare l’immagine, attendi anche se la schermata è freezata
    - Alla richiesta **Would you like to copy …** seleziona **Yes**.
- A VM creata, clicca su `Edit`
  - **General Settings**:
    - **On close:** `Send the shutdown signal (ACPI)`
    - Abilita `Auto start console`
  - **Network:**
    - **Numero di adapters:** `4`
  - **Advanced:**
- Se non abilitato, abilita **Use as a linked base VM**
- Applica e conferma le impostazioni

## Login su macchina virtuale Ubuntu
- **Username:** `root`
- **Password:** `root`

## Attenzione
- Se l’emulazione sembra essere eccessivamente *lenta* anche nell’utilizzo, l’accelerazione hardware è mancante assicurati di aver KVM attivo
- É altamente consigliato spegnere le VM cliccando sul tasto `STOP` della GUI di GNS3, anzichè chiudere le finestre di QEMU. Questo permette alle VM uno spegnimento *non forzato*, in modo da salvaguardare lo stato e il contenuto dell’hard disk virtuale
