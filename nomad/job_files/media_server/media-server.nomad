job "media-server" {

  datacenters = ["dc1"]
  type = "service"

  group "media-server" {
    count = 1

    network {
      mode = "bridge"

      port "plex-http" {
        to = 32400
        static = 32400
      }

      port "plex-dlna" {
        to = 32469
        static = 32469
      }

      port "plex-gdm-1" {
        to = 32410
        static = 32410
      }

      port "plex-gdm-2" {
        to = 32412
        static = 32412
      }

      port "plex-gdm-3" {
        to = 32413
        static = 32413
      }

      port "plex-gdm-4" {
        to = 32414
        static = 32414
      }

      port "plex-avahi" {
        to = 5353
        static = 5353
      }

      port "tautulli-web" {
        to = 8181
        static = 8181
      }

    }

    ###########
    # VOLUMES #
    ###########

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

    volume "plex_conf" {
      type = "host"
      read_only = "false"
      source = "plex_conf"
    }

    volume "plex_transcode" {
      type = "host"
      read_only = "false"
      source = "plex_transcode"
    }

    ############
    # SERVICES #
    ############

    ## Plex service
    service {
      name = "plex-http"
      provider = "consul"
      port = "plex-http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Path(`/plex`)"
      ]
      connect {
        sidecar_service {}
      }
    }

    #########
    # TASKS #
    #########

    ## Plex task
    task "plex" {
      driver = "docker"

      config {
        image = "linuxserver/plex"
        ports = ["plex-http", "plex-dlna", "plex-gdm-1", "plex-gdm-2", "plex-gdm-3", "plex-gdm-4", "plex-avahi"]
        network_aliases = ["plex"]
        network_mode = "download-suite"
        ## /dev/dri is a mount for Intel CPU/GPU for transcoding
        # This only works with Intel/Nvidia devices
        # args = [
        #   "--device /dev/dri:/dev/dri"
        # ]
      }

      env {
        PUID="${PUID}"
        PGID="${PGID}"
        VERSION="${VERSION}"
        ## Get a code from https://www.plex.tv/claim/
        #  The code is good for 4 minutes. Comment this
        #  variable after claiming your instance.
        # PLEX_CLAIM="claim-EuxehT_Gtdco8jZzBDrD"
      }

      volume_mount {
        volume = "movies"
        destination = "/movies"
        read_only = "false"
      }

      volume_mount {
        volume = "tv-shows"
        destination = "/tv"
        read_only = "false"
      }

      volume_mount {
        volume = "plex_conf"
        destination = "/config"
        read_only = "false"
      }

      volume_mount {
        volume = "plex_transcode"
        destination = "/transcode"
        read_only = "false"
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env = true
        change_mode = "restart"
        data = <<EOF
{{- with nomadVar "nomad/jobs/media-server" -}}
PUID = {{ .PUID }}
PGID = {{ .PGID }}
VERSION = "docker"
{{- end -}}
EOF
      ## End Plex Template Block
      }

      ## PLEX resources
      resources {
        # cpu = 5000
        memory = 2048
      }
    }

  }

}