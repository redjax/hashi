job "example-fastapi-db_postgres" {
    datacenters = ["lab1"]
    type = "service"

    group "example-fastapi-db" {
        count = 1
        network {
            port "db" {
                to = 5432
                static = 5432
            }
        }

        service {
            name = "postgres"
            port = "db"
            provider = "consul"

            tags = [
                "traefik.enable=true"
            ]
        }

        task "example-fastapi-postgres" {
            driver = "docker"

            # env {
            #     POSTGRES_USER="postgres"
            #     POSTGRES_PASSWORD="postgres"
            #     PGDATA="/var/lib/postgresql/data/example-fastapi-postgres"
            # }

            config {
                image = "postgres"

                ports = ["db"]

                volumes = [
                    ## Database data directory
                    # "./apps/postgres/data:/var/lib/postgresql/data",
                    "{{ .VOL_PG_DATA }}:/var/lib/postgresql/data",
                    # "./apps/postgres/entrypoint:/docker-entrypoint-initdb.d/",
                    "{{ .VOL_PG_ENTRYPOINT }}:/docker-entrypoint-initdb.d/",
                    # "./apps/postgres/storage:/var/lib/postgresql/data/storage"
                    "{{ .VOL_PG_STORAGE  }}:/var/lib/postgresql/data/storage"
                ]
            }

            ## Load environment from variables configured in Nomad webUI
            template {
                destination = "${NOMAD_SECRETS_DIR}/env.vars"
                env = true
                change_mode = "restart"
                data = <<EOF
{{- with nomadVar "nomad/jobs/example-fastapi-db_postgres" -}}
PGDATA = {{ .PGDATA }} 
POSTGRES_PASSWORD = {{ .POSTGRES_PASSWORD }}
POSTGRES_USER = {{ .POSTGRES_USER }}
VOL_PG_DATA = {{ .VOL_PG_DATA }}
VOL_PG_ENTRYPOINT = {{ .VOL_PG_ENTRYPOINT }}
VOL_PG_STORAGE = {{ .VOL_PG_STORAGE }}
{{- end -}}
EOF
            }

            resources {
                cpu = 1000
                memory = 1024
            }
        }
    }
}
