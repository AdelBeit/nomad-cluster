#!/bin/bash
set -ex

LOG_FILE="/tmp/launch-server.log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Server launch started ==="

cleanup_on_error() {
  local exit_code=$?
  echo "[ERROR] Launch failed with exit code $exit_code"
  echo "[ERROR] Check $LOG_FILE for details"
  systemctl status consul || true
  systemctl status nomad || true
  journalctl -xe -n 50 || true
  exit $exit_code
}
trap cleanup_on_error EXIT

stage() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] --- $1 ---"
}

stage "Copying Consul server config"
sudo cp /vagrant/consul-config/consul-server.hcl /etc/consul.d/consul.hcl
cat /etc/consul.d/consul.hcl

stage "Starting Consul"
sudo systemctl restart consul
sleep 3
systemctl status consul || true
sudo consul version

stage "Copying Nomad server config"
sudo cp /vagrant/nomad-config/nomad-server.hcl /etc/nomad.d/nomad.hcl
cat /etc/nomad.d/nomad.hcl

stage "Starting Nomad"
sudo systemctl restart nomad
sleep 3
systemctl status nomad || true
nomad version

stage "Verifying cluster membership"
sleep 2
nomad server members || true
consul members || true

stage "Building Docker images"
if [ -d /vagrant/hello-world-server ]; then
  docker build -t hello-world-server:v1.0.0 /vagrant/hello-world-server
else
  echo "WARNING: hello-world-server directory not found"
fi

echo ""
echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Server launch complete ==="
touch /tmp/server-launch-complete
