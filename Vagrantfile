# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.boot_timeout = 600

  # ── SERVER NODE ───────────────────────────────────────────────
  config.vm.define "nomad-server" do |s|
    s.vm.hostname = "nomad-server"
    s.vm.network "private_network", ip: "192.168.33.10"

    s.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus   = "2"
    end

    s.vm.provision "shell", path: "node-install.sh"
    s.vm.provision "shell", path: "launch-server.sh", run: 'always'

    # Port forwarding for UI/API access
    s.vm.network "forwarded_port", guest: 4646, host: 4646, auto_correct: true  # Nomad UI
    s.vm.network "forwarded_port", guest: 8500, host: 8500, auto_correct: true  # Consul UI
  end

  # ── CLIENT NODE 1 (runs hello-world-client) ──────────────────
  config.vm.define "nomad-client-1" do |c1|
    c1.vm.hostname = "nomad-client-1"
    c1.vm.network "private_network", ip: "192.168.33.11"

    c1.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus   = "2"
    end

    c1.vm.provision "shell", path: "node-install.sh"
    c1.vm.provision "shell", path: "launch-client.sh", run: 'always'
  end

  # ── CLIENT NODE 2 (runs hello-world-client) ──────────────────
  config.vm.define "nomad-client-2" do |c2|
    c2.vm.hostname = "nomad-client-2"
    c2.vm.network "private_network", ip: "192.168.33.12"

    c2.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus   = "2"
    end

    c2.vm.provision "shell", path: "node-install.sh"
    c2.vm.provision "shell", path: "launch-client.sh", run: 'always'
  end
end
