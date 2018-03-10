#!/bin/bash

. functions.sh

    
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





echo sudo nano /etc/sanoid/sanoid.conf


