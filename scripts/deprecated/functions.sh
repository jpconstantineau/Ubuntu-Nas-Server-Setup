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
  add-apt-repository ppa:gluster/glusterfs-3.11
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
}

function configure_zfs(){
  lsblk
  zpool list

    while true; do
        echo
        read -p "Do you want to use sdb as a single drive Pool? (Y/N) " res
        case $res in
            [Yy]* ) configure_zfs_pool /dev/sdb; break;;
            [Nn]* ) break;;
            * ) echo "Invalid answer";;
        esac
    done
}

function configure_vpn
{
  echo 'AUTOSTART="all"' >> /etc/default/openvpn
}

