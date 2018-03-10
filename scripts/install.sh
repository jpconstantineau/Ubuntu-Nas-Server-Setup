#!/bin/bash

. functions.sh

host=$(hostname -f)

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
        echo "Open VPN Client"
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
    
