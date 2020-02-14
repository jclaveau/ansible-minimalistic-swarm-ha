#! /bin/bash

apt-get update -y && apt-get upgrade -y
apt-get install apt-transport-https software-properties-common ca-certificates ufw -y
apt-get install nmap -y
ufw allow ssh
ufw allow 80/tcp
ufw enable <<< "y"

# Installing Docker
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update -y

apt-get install docker-ce -y

systemctl start docker
systemctl enable docker

groupadd docker && usermod -aG docker dockeruser

ufw allow 2376/tcp
ufw allow 2377/tcp
ufw allow 7946/udp
ufw allow 7946/tcp
ufw allow 4789/udp

ufw reload

systemctl restart docker

# Docker Compose
curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)"
chmod +x /usr/local/bin/docker-compose

# Initializing Swarm
# docker swarm init


# GlusterFS
apt-get install glusterfs-server glusterfs-client -y
systemctl enable glusterfs-server
mkdir -p /gluster/brick 
ufw allow 24007/tcp
ufw allow 24008/tcp
ufw allow 49152/tcp # /gluster/brick
# portmapper
ufw allow 111/tcp
ufw allow 111/udp

# /etc/hosts
hostname="$(cat /etc/hosts | grep '127.0.1.1' | awk '{print $3}')" 
public_ip="$(cat /etc/hosts | grep -v '127.0.1.1' |grep "$hostname" | awk '{print $1}')" 

declare -A nodes
nodes[node1]='37.187.120.21'
nodes[node2]='37.187.121.185'

for node_name in "${!nodes[@]}"
do
    sed -i "/$node_name/d" /etc/hosts
    if [ "${nodes[$node_name]}" == "$public_ip" ]; then
        # https://serverfault.com/questions/531359/why-cant-i-create-this-gluster-volume#531385
        echo -e "127.0.0.1\t$node_name" >> /etc/hosts
    else       
        echo -e "${nodes[$node_name]}\t$node_name" >> /etc/hosts
    fi
done
