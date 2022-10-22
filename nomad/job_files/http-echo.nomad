job "http-echo" {
  datacenters = ["lab1"]
  group "echo" {
    count = 1
    network {
      port "http" {
        to = 8080
        static = 8080
      }
    }
    task "http-echo" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo:latest"
        args  = [
          "-listen", ":8080",
          "-text", "Hello and welcome to 127.0.0.1 running on port 8080",
        ]
        # Use group name from above
        ports = ["http"]
      }

      resources {
        cores = 1
        memory = 528
      }
    }
  }
}