data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

advertise {
  http = "{{ GetPrivateInterfaces | include \"network\" \"192.168.33.0/24\" | attr \"address\" }}"
  rpc  = "{{ GetPrivateInterfaces | include \"network\" \"192.168.33.0/24\" | attr \"address\" }}"
  serf = "{{ GetPrivateInterfaces | include \"network\" \"192.168.33.0/24\" | attr \"address\" }}"
}

server {
  enabled = false
}

client {
  enabled = true
  servers = ["192.168.33.10:4647"]
}
