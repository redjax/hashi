job "example-fastapi" {
    datacenters = ["lab1"]
    type = "service"

    group "example-fastapi" {
        count = 1
        network {
            port "http" {
                to = 8000
            }
        }

        service {
            name = "example-fastapi"
            port = "http"
            provider = "nomad"

            tags = [
                "traefik.enable=true",
                "traefik.http.routers.http.rule=Path(`/example-fastapi`)"
            ]
        }

        task "backend" {
            driver = "docker"

            config {
                image = "localhost:5000/example-fastapi"

                ports = ["http"]

                work_dir = "/app"

                volumes = [
                    "./app:/local/app"
                ]
            }

            resources {
                cores = 1
                memory = 528
            }
        }
    }
}