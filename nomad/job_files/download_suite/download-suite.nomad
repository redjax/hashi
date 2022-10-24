job "download-suite" {

  datacenters = ["dc1"]
  type = "service"

  group "arr-downloaders" {
    count = 1

    network {

      mode = "bridge"
      
      port "radarr" {
        to = 7878
        static = 7878
      }

      port "sonarr" {
        to = 8989
        static = 8989
      }

      port "jackett" {
        to = 9117
        static = 9117
      }

    }

    ###########
    # VOLUMES #
    ###########

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

    volume "sonarr_conf"{
      type = "host"
      read_only = "false"
      source = "sonarr_conf"
    }

    ############
    # SERVICES #
    ############

    ## Radarr Service
    service {
      name = "radarr"
      provider = "consul"
      port = "radarr"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Path(`/radarr`)",
      ]
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "jackett"
              local_bind_port = 7878
            }
          }
        }
      }
    }

    ## Jackett Service
    service {
      name = "jackett"
      provider = "consul"
      port = "jackett"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Path(`/jackett`)",
      ]
      connect {
        sidecar_service {}
      }
    }

    ## Sonarr Service
    service {
      name = "sonarr"
      provider = "consul"
      port = "sonarr"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Path(`/sondarr`)",
      ]
      connect {
        sidecar_service {}
      }
    }

    #########
    # TASKS #
    #########

    ## Radarr Task
    task "radarr" {
      driver = "docker"

      config {
        image = "linuxserver/radarr"
        ports = ["radarr"]
        network_aliases = ["radarr"]
        network_mode = "download-suite"
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

      ## RAADARR resources
      resources {
        cores = 1
        memory = 528
      }

    }

    ## JACKETT TASK
    task "jackett" {
      driver = "docker"

      config {
        image = "linuxserver/jackett"
        ports = ["jackett"]
        network_aliases = ["jackett"]
        network_mode = "download-suite"
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

    ## Sonarr task
    task "sonarr" {
      driver = "docker"

      config {
        image = "linuxserver/sonarr"
        ports = ["sonarr"]
        network_aliases = ["sonarr"]
        network_mode = "download-suite"
      }

      env {
        PUID="${PUID}"
        PGID="${PGID}"
        TZ="${TZ}"
      }

      volume_mount {
        volume = "tv-shows"
        destination = "/tv"
        read_only = "false"
      }

      volume_mount {
        volume = "sonarr_conf"
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
      ## End Sonarr Template Block
      }

      ## SONARR resources
      resources {
        cores = 1
        memory = 528
      }

    }

  }
}