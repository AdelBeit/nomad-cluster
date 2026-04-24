data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

datacenter = "dc1"
region     = "dc1"

advertise {
  http = "{{ GetInterfaceIP `eth1` }}"
  rpc  = "{{ GetInterfaceIP `eth1` }}"
  serf = "{{ GetInterfaceIP `eth1` }}"
}

server {
  enabled = false
}

client {
  enabled = true
  servers = ["nomad-server:4647"]
}

consul {
  address = "127.0.0.1:8500"
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}
