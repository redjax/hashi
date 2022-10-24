job "traefik" {

    datacenters = ["lab1"]
    type = "service"

    group "traefik" {
        count = 1

        network {

            port "http" {
                static = 80
            }

            port "admin" {
                static = 8080
            }

        }

        service {
            name = "traefik-http"
            provider = "nomad"
            port = "http"

            check {
                name     = "alive"
                type     = "tcp"
                port     = "http"
                interval = "10s"
                timeout  = "2s"
            }
        }

        task "server" {
            driver = "docker"

            config {
                image = "traefik:2.9"

                ports = ["admin", "http"]
                
                args = [
                    "--api.dashboard=true",
                    "--api.insecure=true",
                    "--entrypoints.web.address=:${NOMAD_PORT_http}",
                    "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
                    "--providers.nomad=true",
                    "--providers.nomad.endpoint.address=http://192.168.1.22:4646",
                    "--providers.consulcatalog.refreshInterval=30s",
                    # "--providers.consulcatalog.prefix=lab1",
                    "--providers.consulcatalog.endpoint.address=192.168.1.22:8500",
                    "--providers.consulcatalog.endpoint.scheme=http",
                    "--providers.consulcatalog.endpoint.datacenter=lab1",
                    "--providers.consulcatalog.connectAware=true",
                    "--providers.consulcatalog.serviceName=traefik",
                    "--providers.consulcatalog.watch=true"
                ]
            }

            resources {
                cpu = 100
                memory = 256
            }
        }
    }
}