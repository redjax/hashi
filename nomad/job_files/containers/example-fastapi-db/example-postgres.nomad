job "postgres" {
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

            env {
                POSTGRES_USER="postgres"
                POSTGRES_PASSWORD="postgres"
                PGDATA="/var/lib/postgresql/data/example-fastapi-postgres"
            }

            config {
                image = "postgres"

                ports = ["db"]

                volumes = [
                    "./apps/postgres/data:/var/lib/postgresql/data",
                    "./apps/postgres/entrypoint:/docker-entrypoint-initdb.d/",
                    " ./apps/postgres/storage:/var/lib/postgresql/data/storage"
                ]
            }

            resources {
                cpu = 1000
                memory = 1024
            }
        }
    }
}
