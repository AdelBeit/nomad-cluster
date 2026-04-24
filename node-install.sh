#!/bin/bash
set -ex

LOG_FILE="/tmp/provision.log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Provisioning started ==="

cleanup_on_error() {
  local exit_code=$?
  echo "[ERROR] Stage failed with exit code $exit_code"
  echo "[ERROR] Check $LOG_FILE for details"
  exit $exit_code
}
trap cleanup_on_error EXIT

stage() {
  echo ""
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ========== $1 =========="
}

stage "System preparation: apt-get update and base tools"
sudo apt-get update -y
sudo apt-get install -y unzip curl wget vim jq
touch /tmp/stage-1-base-tools.ok

stage "Docker installation"
sudo apt-get remove -y docker docker-engine docker.io || true
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker vagrant
docker version
touch /tmp/stage-2-docker.ok

stage "Nomad installation"
NOMAD_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/nomad | jq -r ".current_version")
echo "Nomad version: $NOMAD_VERSION"
cd /tmp
curl -sSL "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip" -o nomad.zip
unzip -o nomad.zip
sudo install nomad /usr/local/bin/nomad
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d
nomad version
touch /tmp/stage-3-nomad.ok

stage "Consul installation"
CONSUL_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/consul | jq -r ".current_version")
echo "Consul version: $CONSUL_VERSION"
curl -sSL "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip" -o consul.zip
unzip -o consul.zip
sudo install consul /usr/local/bin/consul
sudo mkdir -p /etc/consul.d
sudo chmod a+w /etc/consul.d
consul version
touch /tmp/stage-4-consul.ok

stage "CNI plugins installation"
CNI_VERSION="v1.5.1"
curl -sSL "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" -o cni-plugins.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz
ls /opt/cni/bin | head -5
touch /tmp/stage-5-cni.ok

echo ""
echo "[$(date '+%Y-%m-%d %H:%M:%S')] === All stages completed successfully ==="
touch /tmp/node-install-complete
ls -lah /tmp/stage-*.ok /tmp/node-install-complete
