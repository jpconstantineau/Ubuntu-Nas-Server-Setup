  #!/bin/bash
  
  sudo apt update
  sudo apt upgrade -y
  sudo apt full-upgrade -y
  apt-get autoremove && apt-get autoclean
  
  echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee -a /etc/apt/sources.list
  sudo add-apt-repository universe multiverse
  wget http://www.webmin.com/jcameron-key.asc
  sudo apt-key add jcameron-key.asc
  
  sudo apt update
  
  sudo apt install webmin -y
  sudo apt install autossh -y
  sudo apt install openssh-server  -y
  sudo apt install zfs -y
  sudo apt install zfsutils-linux  -y
  sudo apt install pv mbuffer lzop -y
  sudo apt install libconfig-inifiles-perl -y
  sudo apt install git  -y
  sudo apt install lm-sensors -y
  sudo apt install smartmontools -y
  cd /opt
  sudo git clone https://github.com/jimsalterjrs/sanoid.git
  sudo ln /opt/sanoid/sanoid /usr/sbin/
  sudo ln /opt/sanoid/syncoid /usr/sbin/
  sudo mkdir -p /etc/sanoid
  sudo cp /opt/sanoid/sanoid.conf /etc/sanoid/sanoid.conf
  sudo cp /opt/sanoid/sanoid.defaults.conf /etc/sanoid/sanoid.defaults.conf
  
  ssh-keygen -t rsa -C "your_email@example.com"
  curl -s https://install.zerotier.com | sudo bash
  
 
