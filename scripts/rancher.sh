#!/bin/bash
sudo mount /dev/cdrom /mnt
sudo bash /mnt/Linux/install.sh
sudo umount /dev/cdrom

sudo apt update
sudo apt upgrade -y
sudo apt-get autoremove && apt-get autoclean
sudo apt install rsync -y 

sudo curl https://releases.rancher.com/install-docker/19.03.sh | sh

sudo usermod -aG docker USERNAME

sudo docker run -d -v /data/docker/rancher-server/var/lib/rancher/:/var/lib/rancher/ --restart=unless-stopped --name rancher-server -p 8080:80 -p 8043:443 rancher/rancher:stable
