#!/bin/bash

echo "=== Launching Consul Server ==="
sudo cp /vagrant/consul.hcl /etc/consul.d/consul.hcl
sudo systemctl restart consul
sleep 2

echo "=== Launching Nomad Server ==="
sudo cp /vagrant/nomad.hcl /etc/nomad.d/nomad.hcl
sudo systemctl restart nomad
sleep 2

echo "=== Building Docker images ==="
docker build -t hello-world-server:v1.0.0 /vagrant/hello-world-server

echo "=== Server startup complete ==="
nomad server members
consul members
