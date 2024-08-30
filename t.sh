#!/bin/bash

#Harbor on Ubuntu 18.04
export http_proxy=http://192.168.31.43:7890
export https_proxy=http://192.168.31.43:7890
#Prompt for the user to ask if the install should use the IP Address or Fully Qualified Domain Name of the Harbor Server
PS3='Would you like to install Harbor based on IP or FQDN? '
select option in IP FQDN
do
    case $option in
        IP)
            IPorFQDN=192.168.56.105
            printf "Using IP Address: $IPorFQDN\n"
            break;;
        FQDN)
            IPorFQDN=$(hostname -f)
            break;;
     esac
done

# Housekeeping
apt update -y
swapoff --all
sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
ufw disable #Do Not Do This In Production
echo "Housekeeping done"

#Install Latest Stable Docker Release
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io
tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries" : ["$IPorFQDN:443","$IPorFQDN:80","0.0.0.0/0"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
groupadd docker
MAINUSER=$(logname)
usermod -aG docker $MAINUSER
systemctl daemon-reload
systemctl restart docker
echo "Docker Installation done"

#Install Latest Stable Docker Compose Release
curl -L "https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
echo "Docker Compose Installation done"

#Install Latest Stable Harbor Release
HARBORVERSION=2.11.0
curl -s https://github.com/goharbor/harbor/releases/download/v2.11.0/harbor-offline-installer-v2.11.0.tgz
tar xvf harbor-offline-installer-v2.11.0.tgz
cd harbor
cp harbor.yml.tmpl harbor.yml
sed -i "s/reg.mydomain.com/$IPorFQDN/g" harbor.yml
./install.sh --with-clair --with-chartmuseum
echo -e "Harbor Installation Complete \n\nPlease log out and log in or run the command 'newgrp docker' to use Docker without sudo\n\nLogin to your harbor instance:\n docker login -u admin -p Harbor12345 $IPorFQDN"
