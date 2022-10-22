job "example-fastapi-db" {
    datacenters = ["lab1"]
    type = "service"

    group "example-fastapi-db" {
        count = 1
        network {
            port "http" {
                to = 8000
                static = 8001
            }
        }

        volume "example-fastapi-db-backend" {
           type = "host"
            read_only = "false"
            source = "example-fastapi-db-backend"
        }

        service {
            name = "example-fastapi-db-server"
            port = "http"
            provider = "consul"

            tags = [
                "traefik.enable=true",
                "traefik.http.routers.http.rule=Path(`/fastapi`)"
            ]
        }

        task "backend" {
            driver = "docker"

            env {
                APP_TITLE="Demo FastAPI + Postgres in Nomad"
                APP_DESCRIPTION="FastAPI portion of Nomad + Postgres job group"
                APP_VERSION="0.2"

                LOG_LEVEL="DEBUG"

                DB_TYPE="postgres"
                DB_HOST="192.168.1.22"
                DB_PORT="5432"
                DB_USER="postgres"
                DB_PASSWORD="postgres"
                DB_NAME="test"
            }

            config {
                image = "localhost:5000/example-fastapi-pg"

                ports = ["http"]

                work_dir = "/app"

            }

            volume_mount {
                volume = "example-fastapi-db-backend"
                ## Destination in container
                destination = "/app"
                read_only = "false"
            }

            resources {
                cores = 1
                memory = 528
            }
        }
    }
}