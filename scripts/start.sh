#!/bin/bash
git config --global user.name ""
git config --global user.email "@gmail.com"
git clone https://github.com/jpconstantineau/Ubuntu-Nas-Server-Setup.git
cd Ubuntu-Nas-Server-Setup
cd scripts

    while true; do
        echo
        echo "Select Server Type"
		echo "1 - New Server: Gluster Remote Geo-Replication"
		echo "2 - New Server: Gluster Local Replicate"
		echo "3 - Existing Server: Gluster Remote Geo-Replication"
		echo "4 - Existing Server: Gluster Local Replicate"
        read -p "Select: " res
        case $res in
            [1]* ) ./install.sh ; ./setupremote.sh ; break;;
            [2]* ) ./install.sh ; ./setuplocal.sh ; break;;
			[3]* ) ./setupremote.sh ; break;;
			[4]* ) ./setuplocal.sh ; break;;
            * ) echo "Invalid answer";;
        esac
    done


