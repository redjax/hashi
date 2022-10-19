datacenter = "lab1"
data_dir = "/opt/nomad/data"
bind_addr = "0.0.0.0"

server {
  enabled = true
  bootstrap_expect = 1
}

client {
  enabled = true
  servers = ["127.0.0.1:4646"]

  host_volume "certs" {
    path = "/etc/letsencrypt/live"
    read_only = true
  }

  host_volume "registry" {
    path = "/opt/registry/data"
    read_only = false
  }
}
