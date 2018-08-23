#!/bin/bash

function update_os()
{
  sudo apt update
  sudo apt upgrade -y
  sudo apt full-upgrade -y
  apt-get autoremove && apt-get autoclean
}

function update_vpn
{
  sudo apt install openssh-server  -y
  sudo apt-get install openvpn -y
  apt-get autoremove && apt-get autoclean 
}

function update_monitor(){
  apt install lm-sensors -y
  apt install smartmontools -y
  apt-get autoremove && apt-get autoclean   
}

function update_zfs(){
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

function configure_zfs_pool(){
  zpool create -f StoragePool $1
  zpool status
}

function update_gluster(){
  apt-get install -y software-properties-common
  add-apt-repository ppa:gluster/glusterfs-4.1
  apt-get update
  apt-get install glusterfs-server -y
  apt-mark hold glusterfs*
  apt-get install glusterfs-client -y
  apt-get autoremove && apt-get autoclean 
}

function setup_zfs_gfs(){
  zfs create StoragePool/Gluster
  zfs set atime=off StoragePool/Gluster
  zfs set xattr=sa StoragePool/Gluster
  zfs set exec=off StoragePool/Gluster
  zfs set sync=disabled StoragePool/Gluster
  zfs set compression=lz4 StoragePool
}

function zfs_gfs_configure(){
  zfs create StoragePool/Gluster/$1
  zfs create StoragePool/Gluster/$1/$2
  gluster volume create $1 $host:/StoragePool/Gluster/$1/$2/Brick
  gluster volume start $1
  gluster volume status
  gluster volume info
  mkdir /$1
  chown nobody.nogroup -R /gv0
  chmod 777 -R /gv0
  echo "localhost:/" $1 " /"$1 " glusterfs defaults,_netdev 0 0" >> /etc/fstab
  echo "[gluster-"$1"]" >> /etc/samba/smb.conf
  echo "browseable = yes" >> /etc/samba/smb.conf
  echo "path = /"$1 >> /etc/samba/smb.conf
  echo "guest ok = yes" >> /etc/samba/smb.conf
  echo "read only = no" >> /etc/samba/smb.conf
  echo "create mask = 777" >> /etc/samba/smb.conf  
  
  service smbd restart 
}


function configure_vpn
{
  echo 'AUTOSTART="all"' >> /etc/default/openvpn
}



host=$(hostname)

    while true; do
        echo
        echo "Do you want to update ubuntu?"
        read -p "Do you want to install? (Y/N) " res
        case $res in
            [Yy]* ) update_os ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac
    done

    while true; do
        echo
        echo "OpenVPN Client"
        read -p "Do you want to install? (Y/N) " res
        case $res in
            [Yy]* ) update_vpn; break;;
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
            [Yy]* ) update_monitor ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac
    done
  
      while true; do
        echo
        echo "ZFS"
        read -p "Do you want to install? (Y/N) " res
        case $res in
            [Yy]* ) update_zfs ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac
    done
  
    while true; do
        echo
        echo "GlusterFS"
        read -p "Do you want to install? (Y/N) " res
        case $res in
            [Yy]* ) update_gluster ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac 
    done
    

    
      while true; do
        echo
        echo "Setup GlusterFS on ZFS"
        read -p "Do you want to proceed? (Y/N) " res
        case $res in
            [Yy]* ) setup_zfs_gfs ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac 
    done

       while true; do
        echo
        echo "Create GlusterFS Monitor Dev"
        read -p "Do you want to proceed? (Y/N) " res
        case $res in
            [Yy]* ) zfs_gfs_configure Monitor Brick1 ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac 
    done
 
        while true; do
        echo
        echo "Create GlusterFS Data Dev"
        read -p "Do you want to proceed? (Y/N) " res
        case $res in
            [Yy]* ) zfs_gfs_configure Data Brick1 ; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac 
    done


