## Job file for a local container registry

job "registry" {
  # Replace with the name of your datacenter
  datacenters = ["lab1"]
  type        = "service"

  group "registry" {
    count = 1

    network {
      port "http" {
        to = 5000
      }
    }

    service {
      name = "registry"
      port = "http"
      tags = [
        "http",
        "proxy",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "registry" {
      driver = "docker"

      config {
        image = "registry:2"
        ports = ["http"]
      }

      resources {
        cpu    = 500
        memory = 512
      }

      ## Create the volume mount on your host first
      volume_mount {
        volume      = "registry"
        destination = "/var/lib/registry"
        read_only   = false
      }
    }

    volume "registry" {
      type      = "host"
      read_only = false
      source    = "registry"
    }
  }
}