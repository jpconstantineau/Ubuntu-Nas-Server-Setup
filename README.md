# Ubuntu-Nas-Server-Setup
Documentation and Scripts to setup Ubuntu 16.04 Server as a ZFS-Based NAS with Webmin Administration and ZFS replication

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
### Install GIT
```
sudo apt-get install git-all
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
- Multiple Drives in a vdev (Takes care of the redundancy and expanding vdevs by taking larger drives)
- One or multiple vdev in a pool (Takes cake of merging multiple vdevs by striping)
- Cannot remove vdev from a pool
- Cannot reconfigure a vdev (raidz to mirror or to raidz2)
- Can expand a vdev by replacing one drive by a larger one, resilvering and repeating until all drives are replaced. (may need to have auto expand set to true somewhere for this to happen - not sure where)
- Cannot reduce the size of a vdev or the drives within it
- Zpool is the "root" filesystem
- Zpool can contain multiple datasets
- Zpool can contain multiple zvol (iscsi targets)
- Datasets and zvols can be snapshot.
- Replication is done by sending/receiving snapshots.
- Use lz4 compression - unless you only have compressed media files - they are already compressed. leave it on if not sure.
- Don't use deduplication. Needs heaps of memory.  Google why not.

### Old Hard Drives - Expect them to die!  Replace and Expand as you go:
- Use Mirrors as vdevs
- Add pairs of mirrors to pool
- Pair drives by Size, spread by age
- Allows for expansion by replacing 2 drives.
- rebuilding only stess 1 drive.  Failure of that drive would fail the whole pool - Take backups!!!
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
- Don't use raidz1: rebuild of a Raidz1 would stress all drives during rebuild. Failure of an additional drive during rebuild would fail the whole pool. Probability of failure of pool with raidz1 is higher than for a mirror. With raidz2, a second drive could fail and still be able to rebuild.  If you love your data - choose at least raidz2. 
```
sudo zpool create Pool raidz2 /dev/sdv /dev/sdw /dev/sdx /dev/sdy /dev/sdz
```


## Install SANOID 
### Install steps
todo
### SETUP SANOID
SANOID is manages ZFS snapshots.
```
cd /opt
sudo git clone https://github.com/jimsalterjrs/sanoid.git
sudo ln /opt/sanoid/sanoid /usr/sbin/
sudo mkdir -p /etc/sanoid
sudo cp /opt/sanoid/sanoid.conf /etc/sanoid/sanoid.conf
sudo cp /opt/sanoid/sanoid.defaults.conf /etc/sanoid/sanoid.defaults.conf
```
todo: Something is missing here

### EDIT SANOID CONFIG FILE
see [here for info](https://github.com/jimsalterjrs/sanoid) or [here](https://www.svennd.be/zfs-snapshots-of-proxmox-using-sanoid/)
```
sudo nano /etc/sanoid/sanoid.conf
```
ADD SANOID TO CRONTAB (ROOT)
sudo contab -e

*/5 * * * * /usr/sbin/sanoid --cron


## Root SSH 
By default, root does not have a password but ssh logins are disabled.  The following will change all that!
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
Log in to the server as root using SSH.
Open the /etc/ssh/sshd_config file in your preferred text editor (nano, vi, etc.).
```
sudo nano /etc/ssh/sshd_config
```
Locate the following line: PermitRootLogin yes.
Comment it out and type in:
```
PermitRootLogin yes
```

### SETUP KEYS (https://help.ubuntu.com/lts/serverguide/openssh-server.html)
```
ssh-keygen -t rsa
ssh-copy-id username@remotehost
```

## Install Monitoring Scripts
todo

