job "demo" {
  datacenters = ["google"]

  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
  }

  group "app" {
    count = 1

    task "app" {
      driver = "docker"

      config {
        image = "redis:3.2"
        port_map {
          http = 9090
        }
      }

      resources {
        cpu    = 500
        memory = 256
        network {
          mbits = 10
          port "http" {}
        }
      }
    }

    task "sidecar" {
      driver = "exec"

      config {
        command = "consul"
        args    = [
          "connect", "envoy",
          "-sidecar-for", "app-${NOMAD_ALLOC_ID}",
          "-admin-bind", "${NOMAD_ADDR_envoyadmin}"
        ]
      }

      env {
        PATH="${PATH}:${NOMAD_TASK_DIR}"
      }

      resources {
        network {
          port "ingress" {}
          port "envoyadmin" {}
        }
      }
    }

    task "register" {
      driver = "exec"
      kill_timeout = "10s"

      config {
        command = "bash"
        args = [
          "local/init.sh"
        ]
      }

      env {
        PATH="${PATH}:${NOMAD_TASK_DIR}"
      }

      template {
        data = <<EOH
        {
          "service": {
            "name": "app",
            "ID": "app-{{ env "NOMAD_ALLOC_ID" }}",
            "port": {{ env "NOMAD_PORT_app_http" }},
            "connect": {
              "sidecar_service": {
                "port": {{ env "NOMAD_PORT_sidecar_ingress" }},
                "proxy": {
                  "local_service_address": "{{ env "NOMAD_IP_cobol_http" }}"
                }
              }
            }
          }
        }
        EOH
        destination = "local/service.json"
      }

      template {
        data = <<EOH
        #!/bin/bash
        set -x
        consul services register local/service.json
        trap "consul services deregister local/service.json" INT
        tail -f /dev/null &
        PID=$!
        wait $PID
        EOH

        destination = "local/init.sh"
      }

      resources {
        memory = 100
      }
    }
  }
}