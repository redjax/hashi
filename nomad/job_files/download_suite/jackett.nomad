job "download-suite" {

  datacenters = ["dc1"]
  type = "service"

  group "arr-downloaders" {
    count = 1

    network {
      
      port "jackett" {
        to = 9117
      }

      # port "sonarr" {}

      # port "jackett" {}

    }

    volume "jackett_conf" {
      type = "host"
      read_only = "false"
      source = "jackett_conf"
    }

    volume "jackett_picons" {
      type = "host"
      read_only = "false"
      source = "jackett_picons"
    }

    ## JACKETT SERVICE
    service {
      name = "jackett"
      provider = "consul"
      port = "jackett"
    }

    ## JACKETT TASK
    task "jackett" {
      driver = "docker"

      config {
        image = "linuxserver/jackett"
        ports = ["jackett"]
      }

      env {
        PUID="${PUID}"
        PGID="${PGID}"
        TZ="${TZ}"
      }

      volume_mount {
        volume = "jackett_picons"
        destination = "/picons"
        read_only = "false"
      }

      volume_mount {
        volume = "jackett_conf"
        destination = "/config"
        read_only = "false"
      }

      template {

        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env = true
        change_mode = "restart"
        data = <<EOF
{{- with nomadVar "nomad/jobs/download-suite" -}}
PUID = {{ .PUID }}
PGID = {{ .PGID }}
TZ = {{ .TZ }} 
{{- end -}}
EOF
      ## End Jackett Template Block
      }

      ## JACKETT resources
      resources {
        cores = 1
        memory = 528
      }

    }

  }
}