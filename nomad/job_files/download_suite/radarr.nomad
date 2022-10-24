job "download-suite" {

  datacenters = ["dc1"]
  type = "service"

  group "arr-downloaders" {
    count = 1

    network {
      
      port "radarr" {
        to = 7878
      }

      # port "sonarr" {}

      # port "jackett" {}

    }

    volume "media" {
      type = "host"
      read_only = "false"
      source = "media"
    }

    volume "movies" {
      type = "host"
      read_only = "false"
      source = "movies"
    }

    volume "tv-shows" {
      type = "host"
      read_only = "false"
      source = "tv-shows"
    }

    volume "torrent" {
      type = "host"
      read_only = "false"
      source = "torrent"
    }

    volume "radarr_conf" {
      type = "host"
      read_only = "false"
      source = "radarr_conf"
    }

    ## RADARR SERVICE
    service {
      name = "radarr"
      provider = "consul"
      port = "radarr"
    }

    ## RADARR TASK
    task "radarr" {
      driver = "docker"

      config {
        image = "linuxserver/radarr"
        ports = ["radarr"]
      }

      env {
        PUID="${PUID}"
        PGID="${PGID}"
        TZ="${TZ}"
      }

      volume_mount {
        volume = "movies"
        destination = "/movies"
        read_only = "false"
      }

      volume_mount {
        volume = "radarr_conf"
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
      ## End Radarr Template Block
      }

      ## READARR resources
      resources {
        cores = 1
        memory = 528
      }

    }

  }
}