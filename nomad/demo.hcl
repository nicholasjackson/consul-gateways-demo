job "demo" {
  datacenters = ["google"]

  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
  }

  group "upstream" {
    count = 1

    task "postie" {
      driver = "exec"

      config {
        command = "postie"
        args = [
          "--bind-address=0.0.0.0:9000",
          "--type=upstream"
        ]

        port_map {
          http = 9000
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

      service {
        connect {
          sidecar_service {}
        }
      }
    }

    task "sidecar" {
      driver = "exec"

      config {
        command = "consul"
        args    = [
          "connect", "envoy",
          "-sidecar-for", "upstream-${NOMAD_ALLOC_ID}",
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
            "name": "upstream",
            "ID": "upstream-{{ env "NOMAD_ALLOC_ID" }}",
            "port": {{ env "NOMAD_PORT_postie_http" }},
            "connect": {
              "sidecar_service": {
                "port": {{ env "NOMAD_PORT_sidecar_ingress" }},
                "proxy": {
                  "local_service_address": "{{ env "NOMAD_IP_postie_http" }}",
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

  group "downstream" {
    count = 1

    task "postie" {
      driver = "exec"

      config {
        command = "postie"
        args = [
          "--bind-address=0.0.0.0:9000",
          "--upstream-uri=http://localhost:9001"
        ]

        port_map {
          http = 9000
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

      service {
        connect {
          sidecar_service {}
        }
      }
    }

    task "sidecar" {
      driver = "exec"

      config {
        command = "consul"
        args    = [
          "connect", "envoy",
          "-sidecar-for", "downstream-${NOMAD_ALLOC_ID}",
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
            "name": "downstream",
            "ID": "postie-{{ env "NOMAD_ALLOC_ID" }}",
            "port": {{ env "NOMAD_PORT_postie_http" }},
            "connect": {
              "sidecar_service": {
                "port": {{ env "NOMAD_PORT_sidecar_ingress" }},
                "proxy": {
                  "local_service_address": "{{ env "NOMAD_IP_postie_http" }}",
                  "upstreams": [{
                    "destination_name": "upstream",
                    "local_bind_port": 9001
                  }]
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