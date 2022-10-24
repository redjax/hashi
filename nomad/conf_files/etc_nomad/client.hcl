## Define host volume mounts
# NOTE: If you used Hashi-Up, put this stanza in the client {} block
#   in your /etc/nomad.d/nomad.hcl. It doesn't work in a separate
#   client.hcl file
host_volume "volume_name" {
    path = "/path/on/host"
    read_only = false
}