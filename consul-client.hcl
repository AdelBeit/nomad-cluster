data_dir = "/opt/consul"

client_addr = "0.0.0.0"
bind_addr   = "{{ GetPrivateInterfaces | include \"network\" \"192.168.33.0/24\" | attr \"address\" }}"

server = false

ui_config {
  enabled = false
}

retry_join = ["192.168.33.10"]
