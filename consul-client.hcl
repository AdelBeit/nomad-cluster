# Consul client node configuration
# Used on client VMs that join the central server cluster

data_dir    = "/opt/consul"
client_addr = "0.0.0.0"
bind_addr   = "{{ GetInterfaceIP `eth1` }}"

ui_config {
  enabled = false
}

server       = false
retry_join   = ["192.168.33.10"]
