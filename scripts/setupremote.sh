sudo apt-get update
sudo apt-get upgrade
sudo apt install openssh-server
sudo apt-get install git
sudo apt install zfs
sudo apt install pv mbuffer lzop
sudo apt-get install libconfig-inifiles-perl
sudo apt-get install lm-sensors

cd /opt
sudo git clone https://github.com/jimsalterjrs/sanoid.git
sudo ln /opt/sanoid/sanoid /usr/sbin/
sudo ln /opt/sanoid/syncoid /usr/sbin/
sudo mkdir -p /etc/sanoid
sudo cp /opt/sanoid/sanoid.conf /etc/sanoid/sanoid.conf
sudo cp /opt/sanoid/sanoid.defaults.conf /etc/sanoid/sanoid.defaults.conf

echo sudo nano /etc/sanoid/sanoid.conf

sudo apt-get install openvpn
