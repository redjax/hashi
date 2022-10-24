## Copy this file to: /etc/nomad.d/nomad.hcl

datacenter = "lab1"
data_dir   = "/opt/nomad"
addresses {
  http = "0.0.0.0"
  rpc  = "0.0.0.0"
  serf = "0.0.0.0"
}
server {
  enabled          = true
  bootstrap_expect = 1
  server_join {
    retry_join = ["127.0.0.1"]
  }
}
client {
  enabled = true
  server_join {
    retry_join = ["127.0.0.1"]
  }

  ## Create volume mounts
  host_volume "registry" {
    path = "/opt/nomad/volumes"
    read_only = false
  }
}

## Plugins
