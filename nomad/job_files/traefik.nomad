job "traefik-ingress" {

    datacenters = ["dc1"]
    type = "service"

    group "traefik-ingress" {
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
            provider = "consul"
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
                    ## ${NOMAD_ADDRESS} is loaded from the env.
                    #  Set this variable in Nomad's webUI before running this job.
                    "--providers.nomad.endpoint.address=http://${NOMAD_ADDRESS}:4646",
                    "--providers.consulcatalog.refreshInterval=30s",
                    "--providers.consulcatalog.endpoint.address=${NOMAD_ADDRESS}:8500",
                    "--providers.consulcatalog.endpoint.scheme=http",
                    "--providers.consulcatalog.endpoint.datacenter=${DC_NAME}",
                    "--providers.consulcatalog.connectAware=true",
                    "--providers.consulcatalog.serviceName=traefik-ingress",
                    "--providers.consulcatalog.watch=true"
                ]
            }

            template {
                destination = "${NOMAD_SECRETS_DIR}/env.vars"
                env = true
                change_mode = "restart"
                data = <<EOF
{{- with nomadVar "nomad/jobs/traefik-ingress" -}}
NOMAD_ADDRESS = {{ .NOMAD_ADDRESS }}
DC_NAME = {{ .DC_NAME }}
{{- end -}}
EOF
            }

            resources {
                cpu = 100
                memory = 256
            }
        }
    }
}