# Setting up Rancher on k3s

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

## Install Docker - a Rancher Requirment

```
sudo curl https://releases.rancher.com/install-docker/19.03.sh | sh

sudo usermod -aG docker USERNAME


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
