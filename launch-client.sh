#!/bin/bash

echo "=== Launching Consul Client ==="
sudo cp /vagrant/consul-client.hcl /etc/consul.d/consul.hcl
sudo systemctl restart consul
sleep 2

echo "=== Launching Nomad Client ==="
sudo cp /vagrant/nomad-client.hcl /etc/nomad.d/nomad.hcl
sudo systemctl restart nomad
sleep 2

echo "=== Building Docker images ==="
docker build -t hello-world-client:v1.0.0 /vagrant/hello-world-client

echo "=== Client startup complete ==="
nomad node status
