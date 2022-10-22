## Copy this file to: /etc/consul.d/consul.hcl

datacenter     = "lab1"
data_dir       = "/opt/consul"
advertise_addr = "192.168.1.22"
client_addr    = "0.0.0.0"
retry_join     = ["127.0.0.1"]
ports {
  grpc = 8502
}
addresses {
}
ui               = true
server           = true
bootstrap_expect = 1
connect {
  enabled = true
}
