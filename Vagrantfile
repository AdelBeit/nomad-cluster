# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.boot_timeout = 600

  # ── SERVER NODE ───────────────────────────────────────────────
  config.vm.define "nomad-server" do |s|
    s.vm.hostname = "nomad-server"
    s.vm.network "private_network", ip: "192.168.33.10"

    s.vm.provider "virtualbox" do |vb|
      vb.memory = "1516"
      vb.cpus   = "2"
    end

    s.vm.provision "shell", path: "node-install.sh"
    s.vm.provision "shell", path: "launch-server.sh", run: 'always'

    # Port forwarding for UI/API access
    s.vm.network "forwarded_port", guest: 4646, host: 4646, auto_correct: true  # Nomad UI
    s.vm.network "forwarded_port", guest: 8500, host: 8500, auto_correct: true  # Consul UI
  end

  # ── CLIENT NODES ──────────────────────────────────────────────
  (1..1).each do |i|
    config.vm.define "nomad-client-#{i}" do |c|
      c.vm.hostname = "nomad-client-#{i}"
      c.vm.network "private_network", ip: "192.168.33.#{i+10}"

      c.vm.provider "virtualbox" do |vb|
        vb.memory = "1516"
        vb.cpus   = "2"
      end

      c.vm.provision "shell", path: "node-install.sh"
      c.vm.provision "shell", path: "launch-client.sh", run: 'always'
    end
  end

end
