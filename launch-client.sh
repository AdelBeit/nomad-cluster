#!/bin/bash
set -ex

LOG_FILE="/tmp/launch-client.log"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Client launch started ==="

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

stage "Copying Consul client config"
sudo cp /vagrant/consul-config/consul-client.hcl /etc/consul.d/consul.hcl
cat /etc/consul.d/consul.hcl

stage "Starting Consul"
sudo systemctl restart consul
sleep 3
systemctl status consul || true
sudo consul version

stage "Copying Nomad client config"
sudo cp /vagrant/nomad-config/nomad-client.hcl /etc/nomad.d/nomad.hcl
cat /etc/nomad.d/nomad.hcl

stage "Starting Nomad"
sudo systemctl restart nomad
sleep 3
systemctl status nomad || true
nomad version

stage "Verifying cluster membership"
sleep 2
nomad node status || true
consul members || true

stage "Building Docker images"
if [ -d /vagrant/hello-world-client ]; then
  docker build -t hello-world-client:v1.0.0 /vagrant/hello-world-client
else
  echo "WARNING: hello-world-client directory not found"
fi

echo ""
echo "[$(date '+%Y-%m-%d %H:%M:%S')] === Client launch complete ==="
touch /tmp/client-launch-complete
