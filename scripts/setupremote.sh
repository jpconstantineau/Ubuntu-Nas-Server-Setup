#!/bin/bash

function os_update {

sudo apt update
sudo apt upgrade -y 
sudo apt full-upgrade -y
apt-get autoremove && apt-get autoclean   
}


function vpn_update
{
sudo apt install openssh-server  -y
sudo apt-get install openvpn -y
apt-get autoremove && apt-get autoclean 
echo 'AUTOSTART="all"' >> /etc/default/openvpn
}

function zfs_update
{
sudo apt install openssh-server  -y
sudo apt install zfs -y
sudo apt install pv mbuffer lzop -y
sudo apt install libconfig-inifiles-perl -y
sudo apt install git  -y
cd /opt
sudo git clone https://github.com/jimsalterjrs/sanoid.git
sudo ln /opt/sanoid/sanoid /usr/sbin/
sudo ln /opt/sanoid/syncoid /usr/sbin/
sudo mkdir -p /etc/sanoid
sudo cp /opt/sanoid/sanoid.conf /etc/sanoid/sanoid.conf
sudo cp /opt/sanoid/sanoid.defaults.conf /etc/sanoid/sanoid.defaults.conf

}


function gluster_install
{
apt-get install -y software-properties-common
add-apt-repository ppa:gluster/glusterfs-3.11
apt-get update
apt-get install glusterfs-server -y
apt-mark hold glusterfs*
apt-get install glusterfs-client -y
}

function zfs_gfs
{
zpool create -f StoragePool $1
zpool status
zfs create StoragePool/Gluster

zfs set atime=off Gluster
zfs set xattr=sa Gluster
zfs set exec=off Gluster
zfs set sync=disabled Gluster
zfs set compression=lz4 StoragePool

zfs create StoragePool/Gluster/Vol1
zfs create StoragePool/Gluster/Vol1/Brick1

sudo systemctl status glusterfs-server.service
sudo systemctl enable glusterfs-server.service

gluster peer probe localhost

gluster volume create Vol1 replica 1 transport tcp localhost:/StoragePool/Gluster/Vol1/Brick1 

gluster volume start Vol1

gluster volume status

}
function gluster_configure_zfs
{
lsblk
zpool list

    while true; do
        echo
        read -p "Do you want to use sdb? (Y/N) " res
        case $res in
            [Yy]* ) zfs_gfs /dev/sdb; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac
    done

}

function monitor_update
{
apt install lm-sensors -y
apt install smartmontools -y
apt-get autoremove && apt-get autoclean   
}

    while true; do
        echo
        echo "Do you want to update ubuntu?"
        read -p "Do you want to install? (Y/N) " res
        case $res in
            [Yy]* ) os_update; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac
    done

    while true; do
        echo
        echo "Open VPN Client"
        read -p "Do you want to install? (Y/N) " res
        case $res in
            [Yy]* ) vpn_update; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac
    done

    while true; do
        echo
        echo "Samba File Server"
        read -p "Do you want to install? (Y/N) " res
        case $res in
            [Yy]* ) sudo apt install samba -y ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac
    done

    while true; do
        echo
        echo "RSync Backup"
        read -p "Do you want to install? (Y/N) " res
        case $res in
            [Yy]* ) sudo apt install rsync -y ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac
    done

    while true; do
        echo
        echo "Monitoring"
        read -p "Do you want to install? (Y/N) " res
        case $res in
            [Yy]* ) monitor_update ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac
    done
  
      while true; do
        echo
        echo "ZFS"
        read -p "Do you want to install? (Y/N) " res
        case $res in
            [Yy]* ) zfs_update ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac
    done
  
    while true; do
        echo
        echo "GlusterFS"
        read -p "Do you want to install? (Y/N) " res
        case $res in
            [Yy]* ) gluster_install ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac 
    done
    
    
      while true; do
        echo
        echo "Setup GlusterFS on ZFS"
        read -p "Do you want to proceed? (Y/N) " res
        case $res in
            [Yy]* ) gluster_configure_zfs ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac 
    done

 
 





echo sudo nano /etc/sanoid/sanoid.conf


