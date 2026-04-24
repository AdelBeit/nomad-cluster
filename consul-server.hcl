data_dir = "/opt/consul"
client_addr = "0.0.0.0"
ui_config{
  enabled = true
}
server = true
bind_addr = "0.0.0.0"
advertise_addr = "{{ GetInterfaceIP `eth1` }}"
bootstrap_expect=1
