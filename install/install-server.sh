#!/bin/bash

# Check if is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi

# Update installed packages
echo "Update installed packages"
apt-get update && apt-get upgrade -y

# Install utils packages
echo "Install utils packages"
apt-get install -y software-properties-common curl git zip ca-certificates --no-install-recommends
echo

# Install PHP7
echo "Install PHP7"
apt-get update && apt-get install -y php7.0 php7.0-fpm php7.0-curl --no-install-recommends
echo

# Install Composer
echo "Install Composer"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
echo


# IPTABLE
cd ~
wget https://raw.githubusercontent.com/SiddhyN/shell-scripts/master/install/firewall.sh
chmod +x firewall.sh

mv firewall.sh /etc/init.d/
update-rc.d firewall.sh defaults

# FAIL2BAN : https://github.com/fail2ban/fail2ban
cd ~
wget https://github.com/fail2ban/fail2ban/archive/0.9.6.tar.gz
tar zxvf 0.9.6.tar.gz
cd fail2ban-0.9.6
python3 setup.py install

# Ajout au démarrage
cp files/debian-initd /etc/init.d/fail2ban
update-rc.d fail2ban defaults
service fail2ban start

# config avanced
echo "Fail2Ban Avanced config. Do not forget to set your IP in /etc/fail2ban/jail.local and reload service"
cd /etc/fail2ban
wget https://raw.githubusercontent.com/SiddhyN/shell-scripts/master/install/jail.local
service fail2ban reload

# Docker
echo "Install Docker"
apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual apt-transport-https --no-install-recommends
curl -fsSL https://yum.dockerproject.org/gpg | apt-key add -
add-apt-repository "deb https://apt.dockerproject.org/repo/ ubuntu-$(lsb_release -cs) main"
apt-get update && apt-get install -y docker-engine
echo

# Rancher
echo "Start Rancher server"
docker run -d --restart=unless-stopped -p 8080:8080 rancher/server:latest
echo