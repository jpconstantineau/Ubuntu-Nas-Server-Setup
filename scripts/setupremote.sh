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
}

function zfs_update
{
sudo apt install openssh-server  -y
sudo apt install zfs -y
sudo apt install pv mbuffer lzop -y
sudo apt install libconfig-inifiles-perl -y

cd /opt
sudo git clone https://github.com/jimsalterjrs/sanoid.git
sudo ln /opt/sanoid/sanoid /usr/sbin/
sudo ln /opt/sanoid/syncoid /usr/sbin/
sudo mkdir -p /etc/sanoid
sudo cp /opt/sanoid/sanoid.conf /etc/sanoid/sanoid.conf
sudo cp /opt/sanoid/sanoid.defaults.conf /etc/sanoid/sanoid.defaults.conf

}

function monitor_update
{
sudo apt install lm-sensors -y
sudo apt install smartmontools -y
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
            [Yy]* ) zfs_update; break;;
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
        echo "Monitoring"
        read -p "Do you want to install? (Y/N) " res
        case $res in
            [Yy]* ) monitor_update ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac
    done
sudo apt install git  -y






echo sudo nano /etc/sanoid/sanoid.conf


