# Setting up Rancher on RKE

## Ubuntu Installation
  - Download latest LTS version [here](https://www.ubuntu.com/download/server)
  - Install on Server
  - Select default options
  
## if installing in XCP-NG, install VM tools

```
sudo mount /dev/cdrom /mnt
sudo bash /mnt/Linux/install.sh
sudo umount /dev/cdrom

```

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
### Install ZFS - if physical machine
```
sudo apt install zfsutils-linux
```

## Install MOTD
```
sudo apt-get install git update-motd figlet smartmontools -y
git clone https://github.com/jpconstantineau/MOTD.git
cd MOTD
sudo chown root:root *
sudo cp 10-display-name /etc/update-motd.d/
sudo cp 20-sysinfo /etc/update-motd.d/
sudo cp 29-zfs /etc/update-motd.d/
sudo cp 30-hdd-free /etc/update-motd.d/
sudo cp 31-hdd-age /etc/update-motd.d/
sudo cp 40-services /etc/update-motd.d/

sudo chmod -x /etc/update-motd.d/10-help-text
sudo chmod -x /etc/update-motd.d/50-motd-news

sudo update-motd
```

## Install Docker - a Rancher Requirment

```
sudo curl https://releases.rancher.com/install-docker/19.03.sh | sh

sudo usermod -aG docker $USER

```

## If installing RKE

```
curl -L -o rke  https://github.com/rancher/rke/releases/download/v1.1.0/rke_linux-amd64 
sudo chmod +x rke
sudo cp ./rke /usr/local/bin/
rke --version

```

## Create a KRE Config File

```
rke config
```


## If installing Rancher

```
sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher
```

```

docker run -d -v /data/docker/rancher-server/var/lib/rancher/:/var/lib/rancher/ --restart=unless-stopped --name rancher-server -p 80:80 -p 443:443 rancher/rancher:stable
```


## If installing k3s
```
curl -sfL https://get.k3s.io | sh -

```




