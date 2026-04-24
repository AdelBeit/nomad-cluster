#!/bin/bash
set -e

echo "=== Installing base tools ==="
sudo apt-get update -y
sudo apt-get install -y unzip curl wget vim jq

echo "=== Installing Docker ==="
sudo apt-get remove -y docker docker-engine docker.io || true
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker vagrant

echo "=== Installing Nomad ==="
NOMAD_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/nomad | jq -r ".current_version")
cd /tmp
curl -sSL "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" -o nomad.zip
unzip -o nomad.zip
sudo install nomad /usr/local/bin/nomad
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d

echo "=== Installing Consul ==="
CONSUL_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/consul | jq -r ".current_version")
curl -sSL "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" -o consul.zip
unzip -o consul.zip
sudo install consul /usr/local/bin/consul
sudo mkdir -p /etc/consul.d
sudo chmod a+w /etc/consul.d

echo "=== Installing CNI plugins ==="
CNI_VERSION="v1.5.1"
curl -sSL "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" -o cni-plugins.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

echo "=== Installation complete ==="
nomad version
consul version
docker version
