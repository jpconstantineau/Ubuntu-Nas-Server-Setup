# Ubuntu-Nas-Server-Setup
Documentation and Scripts to setup Ubuntu 16.04 Server as a ZFS-Based NAS with Webmin Administration and ZFS replication between servers

When in a mixed UBUNTU/FREENAS environment and wanting ZFS replication between one system and another, it's easier to just setup root ssh on all the machines and setup ssh keys to allow logins.  This may not be the most secure setup, however, this is how I was able to get ZFS replication between FREENAS and UBUNTU to play nice. 

## Ubuntu Installation
  - Download latest LTS version [here](https://www.ubuntu.com/download/server)
  - Install on Server
  - Select default options
  
## Update Ubuntu Packages
```
sudo apt-get update
sudo apt-get upgrade
```
## Install Required Libraries
### INSTALL SSH SERVER (if not already installed)
```
sudo apt install openssh-server
```

### Install GIT: [help here](https://help.ubuntu.com/lts/serverguide/git.html)
```
sudo apt-get install git
```
### Install ZFS
```
sudo apt install zfs
```
### Install Packages needed by SANOID
```
sudo apt install pv mbuffer lzop
sudo apt-get install libconfig-inifiles-perl
```

## Install Webmin for Easy Windows Shares Administration
We need webmin as a source:
```
sudo nano /etc/apt/sources.list
```
Add the following to the list
```
deb http://download.webmin.com/download/repository sarge contrib
```
Save the file and exit the editor.
Next, add the Webmin PGP key so that your system will trust the new repository:
```
wget http://www.webmin.com/jcameron-key.asc
sudo apt-key add jcameron-key.asc
```
Next, update the list of packages to include the Webmin repository:
```
sudo apt-get update 
```
Then install Webmin:
```
sudo apt-get install webmin 
```

## Temperature Sensors
```
sudo apt-get install lm-sensors
```
Check Temperatures:
```
sensors
```

## Configure Drives and ZFS 
### ZFS Primer & [Cheat Sheet](https://www.csparks.com/ZFS%20Without%20Tears.html)
- Multiple Drives in a vdev (Takes care of the redundancy and expanding vdevs by replacing with larger drives)
- One or multiple vdev in a pool (Takes cake of merging multiple vdevs by striping)
- Cannot remove vdev from a pool
- Don't add a single drive to a pool - it will be added as a single drive vdev and you are screwed - you cannot remove it.
- Cannot reconfigure a vdev (raidz to mirror or to raidz2)
- Can expand a vdev by replacing one drive by a larger one, resilvering and repeating until all drives are replaced. (may need to have auto expand set to true somewhere for this to happen - not sure where)
- Cannot reduce the size of a vdev or the drives within it
- Zpool is the "root" filesystem
- Zpool can contain multiple datasets
- Zpool can contain multiple zvol (iscsi targets)
- Datasets and zvols can be snapshoted. zpools cannot.
- Replication is done by sending/receiving snapshots.
- Use lz4 compression - unless you only have compressed media files - they are already compressed. leave it on if not sure.
- Don't use deduplication. Needs heaps of memory.  Google why not.

### Old Hard Drives - Expect them to die!  Replace and Expand as you go:
- Use Mirrors as vdevs
- Add pairs of mirrors to pool
- Pair drives by Size, spread by age
- Allows for expansion by replacing 2 drives.
- Rebuilding only stess 1 drive.  Failure of that drive would fail the whole pool - Take backups!!!
- Run a long test and check their SMART Settings
```
sudo smartctl -t long /dev/sda
sudo smartctl -a /dev/sda | more
```
Write down the Manufacturers, Model, Capacity, serial numbers, and key SMART metrics.
Most important SMART metrics: 
- | ID | Description | Comment |
- | 1 | Raw_Read_Error_Rate | Useless for Seagate Drives |
- | 5 | Reallocated_Sector_Ct | Backblaze |
- | 9 | Power_On_Hours | Good indicator of age |
- | 193 | Load/Unload Cycle Count | Secondary indicator of age (wear) |
- | 196 | Reallocated_Event_Count | Not available on Seagate - Backblaze |
- | 197 | Current_Pending_Sector | Backblaze |
- | 198 | Offline_Uncorrectable |  |
- | 231 | SSD Life Left | Good for SSDs |

Create first pair:  (update device)
```
sudo zpool create Pool mirror /dev/sdx /dev/sdy
```
Create subsequent pairs:  (update device)
```
sudo zpool add Pool mirror /dev/sdx /dev/sdy
```
Check Status of pool:
```
sudo zpool status
```


### New Drives - 5 or more
- Use raidz2 or mirrors (2,4 drives) (see above for mirrors)
- Don't use raidz1: rebuild of a Raidz1 would stress all drives during rebuild. Failure of an additional drive during rebuild would fail the whole pool. Probability of failure of a pool with raidz1 during rebuild is higher than for a mirror. With raidz2, a second drive could fail and still be able to rebuild.  If you love your data - choose at least raidz2. 
```
sudo zpool create Pool raidz2 /dev/sdv /dev/sdw /dev/sdx /dev/sdy /dev/sdz
```

### File-based Pool on SSD for replication of config and monitoring data to central location 
Good info [here](https://pthree.org/2012/12/04/zfs-administration-part-i-vdevs/) on how to create file vdevs.
A root folder "zfs" is created to place our preallocated files.
Note that this is configured with no mirroring or redundancy. Each file is a vdev.  By adding files we can increase the size of this pool.  By having the files on a SSD, we can segregate all of our recurring tasks to this pool so that the drives of the HDD pool can be placed to sleep - if needed.
By having the monitoring results stored on a dataset, we can setup regular snapshots and regular replication to the central machine. This way, we don't need to open up NFS or SMB shares. By not having a SMB server on a machine, it makes it a bit more "invisible"; especially when looking for windows shares.
```
sudo mkdir /zfs
sudo dd if=/dev/zero of=/zfs/filePool1 bs=1G count=4
sudo zpool create MonitorPool /zfs/filePool1
sudo zfs create MonitorPool/monitor
```
If you need to increase the size of this pool, all you need to do is create a second file and add it to the pool.  
```
sudo dd if=/dev/zero of=/zfs/filePool2 bs=1G count=4
sudo zpool add MonitorPool /zfs/filePool2
```

## Configure ZFS datasets
Let's setup the ZFS Datasets (root folders within the Pool)
First, turn on a few default options on the pool:
```
sudo zfs set compression=on Pool
sudo zfs set compression=lz4 Pool
```
If you are considering not needing access times information, you can run this command: 
```
sudo zfs set atime=off Pool
```
This will enable you to sleep the drives of your pool.  The command below sets up the sleep timing to 20 minutes: 
```
sudo hdparm -S 240 /dev/sda
```
To see the state of the drive:
```
hdparm -C /dev/sda
```
see [here](https://rudd-o.com/linux-and-free-software/tip-letting-your-zfs-pool-sleep) for more sleeping tips. 

### Create datasets for local data:
```
sudo zfs create Pool/LocalData
```
Don't create datasets that you will replicate from remote to the local server.  These will be created by Syncoid when you do your first replication.


## Install SANOID 
SANOID manages ZFS snapshots. It also includes Syncoid which enables easy replication of ZFS snapshots between servers.

### Install steps
- Install Sanoid on local server (Source)
- Configure Snapshots on local server 
- Install Sanoid on remote server (Destination)
- Configure Snapshots on remote server (to ensure deletion of ol snapshots)

### SETUP SANOID
Make sure GIT and other libraries are first installed - as per steps above.
```
cd /opt
sudo git clone https://github.com/jimsalterjrs/sanoid.git
sudo ln /opt/sanoid/sanoid /usr/sbin/
sudo ln /opt/sanoid/syncoid /usr/sbin/
sudo mkdir -p /etc/sanoid
sudo cp /opt/sanoid/sanoid.conf /etc/sanoid/sanoid.conf
sudo cp /opt/sanoid/sanoid.defaults.conf /etc/sanoid/sanoid.defaults.conf
```

### EDIT SANOID CONFIG FILE
see [here for info](https://github.com/jimsalterjrs/sanoid) or [here](https://www.svennd.be/zfs-snapshots-of-proxmox-using-sanoid/)
```
sudo nano /etc/sanoid/sanoid.conf
```
The first portion of the config file configures the snapshots and how long they are kept.
The second portion of the config file configures the various strategies as templates.  By default, I use templates since they can be applied across all pools and datasets that I manage.  I use template_production at all the sources and template_backup for all the backups.

### ADD SANOID TO CRONTAB (ROOT)
This will schedule the snapshots.
```
sudo contab -e
```
Add this line
```
*/5 * * * * /usr/sbin/sanoid --cron
```
If you want to replicate between UBUNTU machines, you will need to run Sanoid and Syncoid as root since only root has zfs and zpool permissions. (you need sudo to run Sanoid and Syncoid handles ZFS snapshots)  If you want to do remote replication, you aslo need to setup passwordless SSH (using keys). Unfortunately, this means root ssh between server using keys.

## Root SSH 
By default, root does not have a password and ssh logins are disabled.  The following will change all that!
### CHANGE ROOT PASSWORD:
```
sudo passwd root
```
### UNLOCK ROOT ACCOUNT:
```
sudo passwd -u root 
```
### LOCK ROOT ACCOUNT
```
sudo passwd -l root
```

### Allowing/Disabling ROOT SSH:
Log in to the server.
Open the /etc/ssh/sshd_config file in your preferred text editor (nano, vi, etc.).
```
sudo nano /etc/ssh/sshd_config
```
Locate the following line: PermitRootLogin yes.
Comment it out and type in:
```
PermitRootLogin yes
```
You will need to restart the sshd service for this change to take effect.
```
```

### SETUP KEYS [more here](https://help.ubuntu.com/lts/serverguide/openssh-server.html)
To get the root keys created and exchanged between the local and remote machines, log in locally as root:
```
ssh root@localhost
```
Enter the password you used above when you unlocked the account.
Then you can generate the key for the root user and send it to the remote server.
```
ssh-keygen -t rsa
ssh-copy-id root@remotehost
```
Follow the prompts.
Test out that root on the local machine can access the remote machine without password:
```
ssh root@remotehost
```
If this work, syncoid crontab scripts should be able to successfully replicate between the local machine and the remote host - as long as the scripts run on the local machine.  Exit twice and you should be back on your own user on the local machine.

### re-securing root SHH
todo [check here] (https://askubuntu.com/questions/115151/how-to-setup-passwordless-ssh-access-for-root-user)

```
PermitRootLogin without-password  
RSAAuthentication yes
PubkeyAuthentication yes
```

## Setup Replication using Syncoid.
If you have 2 local pools, you can easily call Sanoid:
```
sudo syncoid datapool/dataset backuppool/dataset
```
If you need to replicate between a local and remote server by pushing a local dataset to a remote zfs pool:
```
sudo syncoid localpooldata/dataset root@remotehost:remotepoolbackup/dataset
```
If you need to replicate between a remote and local server by pulling a remote dataset to a local zfs pool:
```
sudo syncoid root@remotehost:remotepooldata/dataset localpoolbackup/dataset
```
This is the only method by which I was able to replicate a from FREENAS to Ubuntu.  Let me know if you know of a better way.



## Install Monitoring Scripts
todo

