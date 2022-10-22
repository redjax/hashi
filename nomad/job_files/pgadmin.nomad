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

            env {
                PGADMIN_DEFAULT_EMAIL="admin@example.com"
                PGADMIN_DEFAULT_PASSWORD="pgadmin"
                PGADMIN_LISTEN_PORT="5050"
                PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION="False"
                PGADMIN_SERVER_JSON_FILE="/servers.json"
            }

            config {
                image = "dpage/pgadmin4"
                ports = ["http"]   

                volumes = [
                    "local/servers.json:/servers.json",
                    "local/servers.passfile:/root/.pgpass"
                ]
            }

            ## local/servers.passfile
            # Note: Passfile data is formatted as:
            #   hostname:port:database:username:password
            template {
                perms = "600"
                change_mode = "noop"
                destination = "local/servers.passfile"
                data = <<EOH
192.168.1.22:5432:postgres:postgress:postgres
EOH
            }

            ## local/servers.json
            template {
                change_mode = "noop"
                destination = "local/servers.json"

                # If "Password" doesn't work, use this: "PassFile": "/root/.pgpass",
                data = <<EOH
{
    "Servers": {
        "1": {
            "Name": "Example FastAPI + Postgres",
            "Group": "Example Servers",
            "Port": 5432,
            "Username": "postgres",
            "Password": "postgres",
            "Host": "192.168.1.22",
            "SSLMode": "disable",
            "MaintenanceDB": "postgres"
        }
    }
}
EOH
            }

            resources {
                cpu = 4000
                memory = 1024
            }
        }
    }
}