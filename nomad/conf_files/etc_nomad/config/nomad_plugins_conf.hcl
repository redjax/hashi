## Copy this file to: /etc/nomad.d/config/plugins.hcl
plugin "docker" {
  config {
    allow_privileged = true
  }
}
