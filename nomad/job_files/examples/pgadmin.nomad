job "pgadmin4" {
    datacenters = ["lab1"]
    type = "service"

    group "pgadmin" {
        count = 1

        network {
            port "http" {
                to = 5050
                static = 5050
            }
        }

        service {
            name = "pgadmin"
            port = "http"
            provider = "consul"

            tags = [
                "traefik.enable=true",
                "traefik.http.routers.http.rule=Path(`/pgadmin`)"
            ]
        }

        task "pgadmin4" {
            driver = "docker"

            # env {
            #     PGADMIN_DEFAULT_EMAIL="{{ .PGADMIN_DEFAULT_EMAIL }}"
            #     PGADMIN_DEFAULT_PASSWORD="{{ .PGADMIN_DEFAULT_PASSWORD }}"
            #     PGADMIN_LISTEN_PORT={{ .PGADMIN_LISTEN_PORT }}
            #     PGADMIN_SERVER_JSON_FILE="/servers.json"
            # }

            config {
                image = "dpage/pgadmin4"
                ports = ["http"]   

                volumes = [
                    "local/servers.json:/servers.json",
                    "local/servers.passfile:/root/.pgpass"
                ]
            }

            ## Load env vars from Nomad variables
            template {
                destination = "${NOMAD_SECRETS_DIR}/env.vars"
                env = true
                change_mode = "restart"
                data = <<EOH
{{- with nomadVar "nomad/jobs/pgadmin4" -}}
PGADMIN_SERVER_JSON_FILE="/servers.json"
PGADMIN_DEFAULT_EMAIL={{ .PGADMIN_DEFAULT_EMAIL }}
PGADMIN_DEFAULT_PASSWORD={{ .PGADMIN_DEFAULT_PASSWORD }}
PGADMIN_LISTEN_PORT={{ .PGADMIN_LISTEN_PORT }}
{{- end -}}
EOH
            }

            ## local/servers.passfile
            # Note: Passfile data is formatted as:
            #   hostname:port:database:username:password
            template {
                perms = "600"
                change_mode = "noop"
                destination = "local/servers.passfile"
                data = <<EOH
{{ .SERVER1_PASSFILE_HOST }}:{{ .SERVER1_PASSFILE_PORT }}:{{ .SERVER1_PASSFILE_DB }}:{{ .SERVER1_PASSFILE_USERNAME }}:{{ .SERVER1_PASSFILE_PASSWORD }}
EOH
            }

            ## local/servers.json
            template {
                change_mode = "noop"
                destination = "local/servers.json"

                # If "Password" doesn't work, use this: "PassFile": "/root/.pgpass",
                data = <<EOH
{{- with nomadVar "nomad/jobs/pgadmin4" -}}
{
    "Servers": {
        "1": {
            "Name": "{{ .SERVER1_PGDB_NAME }}",
            "Group": "Example Servers",
            "Port": {{ .SERVER1_PASSFILE_PORT }},
            "Username": "{{ .SERVER1_PASSFILE_USERNAME }}",
            "Password": "{{ .SERVER1_PASSFILE_PASSWORD }}",
            "PassFile": "/root/.pgpass",
            "Host": "{{ .SERVER1_PASSFILE_HOST }}",
            "SSLMode": "disable",
            "MaintenanceDB": "postgres"
        }
    }
}
{{- end -}}
EOH
            }

            resources {
                cpu = 4000
                memory = 1024
            }
        }
    }
}