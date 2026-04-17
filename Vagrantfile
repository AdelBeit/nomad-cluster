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

    s.vm.provision "shell", inline: <<-SHELL
      # Install HashiCorp packages
      wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
      apt-get update && apt-get install -y docker.io nomad consul

      # Enable Docker
      systemctl enable docker && systemctl start docker
      usermod -aG docker vagrant

      # Install CNI plugins
      curl -L -o /tmp/cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz"
      mkdir -p /opt/cni/bin && tar -C /opt/cni/bin -xzf /tmp/cni-plugins.tgz

      # Configure Consul
      cp /vagrant/consul.hcl /etc/consul.d/consul.hcl
      systemctl enable consul && systemctl start consul

      # Configure Nomad
      cp /vagrant/nomad.hcl /etc/nomad.d/nomad.hcl
      systemctl enable nomad && systemctl start nomad

      # Build Docker image
      docker build -t hello-world-server:v1.0.0 /vagrant/hello-world-server
    SHELL
  end

  # ── CLIENT NODE 1 (runs hello-world-client) ──────────────────
  config.vm.define "nomad-client-1" do |c1|
    c1.vm.hostname = "nomad-client-1"
    c1.vm.network "private_network", ip: "192.168.33.11"

    c1.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus   = "2"
    end

    c1.vm.provision "shell", inline: <<-SHELL
      # Install HashiCorp packages
      wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
      apt-get update && apt-get install -y docker.io nomad consul

      # Enable Docker
      systemctl enable docker && systemctl start docker
      usermod -aG docker vagrant

      # Install CNI plugins
      curl -L -o /tmp/cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz"
      mkdir -p /opt/cni/bin && tar -C /opt/cni/bin -xzf /tmp/cni-plugins.tgz

      # Configure Consul
      cp /vagrant/consul-client.hcl /etc/consul.d/consul.hcl
      systemctl enable consul && systemctl start consul

      # Configure Nomad
      cp /vagrant/nomad-client.hcl /etc/nomad.d/nomad.hcl
      systemctl enable nomad && systemctl start nomad

      # Build Docker image
      docker build -t hello-world-client:v1.0.0 /vagrant/hello-world-client
    SHELL
  end

  # ── CLIENT NODE 2 (runs hello-world-client) ──────────────────
  config.vm.define "nomad-client-2" do |c2|
    c2.vm.hostname = "nomad-client-2"
    c2.vm.network "private_network", ip: "192.168.33.12"

    c2.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus   = "2"
    end

    c2.vm.provision "shell", inline: <<-SHELL
      # Install HashiCorp packages
      wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
      apt-get update && apt-get install -y docker.io nomad consul

      # Enable Docker
      systemctl enable docker && systemctl start docker
      usermod -aG docker vagrant

      # Install CNI plugins
      curl -L -o /tmp/cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz"
      mkdir -p /opt/cni/bin && tar -C /opt/cni/bin -xzf /tmp/cni-plugins.tgz

      # Configure Consul
      cp /vagrant/consul-client.hcl /etc/consul.d/consul.hcl
      systemctl enable consul && systemctl start consul

      # Configure Nomad
      cp /vagrant/nomad-client.hcl /etc/nomad.d/nomad.hcl
      systemctl enable nomad && systemctl start nomad

      # Build Docker image
      docker build -t hello-world-client:v1.0.0 /vagrant/hello-world-client
    SHELL
  end
end
