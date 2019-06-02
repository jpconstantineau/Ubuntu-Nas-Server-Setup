On Server Side:
Go through setup process for the deamon indicated [here](https://help.ubuntu.com/community/rsync#Configuration_of_the_rsync_Daemon)

Setup zfs dataset for backups:
zfs create Pool/backups

check that compresion is on:

zfs get compression Pool/Backups

On Client Side (Windows):
Install rsync using cygwin 64

Go to https://www.cygwin.com/

Install Cygwin by running setup-x86_64.exe
- Install from Internet

Root Directory: 'C:\cygwin64"
"All Users"

Select these packages:
\all\net\rsync 
\all\net\openssh 

"next", "next", "finish"

Copy scripts to windows machine.

Edit target computer

Run as administrator
