#!/bin/bash
git config --global user.name ""
git config --global user.email "@gmail.com"
git clone https://github.com/jpconstantineau/Ubuntu-Nas-Server-Setup.git
cd Ubuntu-Nas-Server-Setup
cd scripts
./setupremote.sh
