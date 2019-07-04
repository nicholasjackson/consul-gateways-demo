job "demo-v2" {
  datacenters = ["google"]

  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
  }

  group "upstream" {
    count = 1

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    task "postie" {
      driver = "exec"

      config {
        command = "postie"
        args = [
          "--bind-address=127.0.0.1:${NOMAD_PORT_http}",
          "--type=upstream"
        ]
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
          "-sidecar-for", "upstream-${NOMAD_ALLOC_ID}",
          "-admin-bind", "127.0.0.1:${NOMAD_PORT_envoyadmin}"
        ]
      }

      env {
        PATH="${PATH}:${NOMAD_TASK_DIR}"
      }

      resources {
        network {
          port "ingress" {}
          port "envoyadmin" {}
          port "metrics" {}
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
          "services": [{
            "name": "upstream",
            "ID": "upstream-{{ env "NOMAD_ALLOC_ID" }}",
            "port": {{ env "NOMAD_PORT_postie_http" }},
            "meta": {
              "version": "2"
            },
            "connect": {
              "sidecar_service": {
                "port": {{ env "NOMAD_PORT_sidecar_ingress" }},
                "proxy": {
                  "local_service_address": "127.0.0.1",
                  "config": {
                    "envoy_prometheus_bind_addr": "0.0.0.0:{{ env "NOMAD_PORT_sidecar_metrics" }}"
                  }
                }
              }
            }
          },
          {
            "name": "metrics",
            "ID": "metrics-{{ env "NOMAD_ALLOC_ID" }}",
            "port": {{ env "NOMAD_PORT_sidecar_metrics" }}
          }]
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

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    task "postie" {
      driver = "exec"

      config {
        command = "postie"
        args = [
          "--bind-address=127.0.0.1:${NOMAD_PORT_http}",
          "--upstream-uri=http://127.0.0.1:${NOMAD_PORT_sidecar_upstream}"
        ]
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
          "-sidecar-for", "downstream-${NOMAD_ALLOC_ID}",
          "-admin-bind", "127.0.0.1:${NOMAD_PORT_envoyadmin}"
        ]
      }

      env {
        PATH="${PATH}:${NOMAD_TASK_DIR}"
      }

      resources {
        network {
          port "ingress" {}
          port "upstream" {}
          port "envoyadmin" {}
          port "metrics" {}
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
          "services": [{
            "name": "downstream",
            "ID": "downstream-{{ env "NOMAD_ALLOC_ID" }}",
            "port": {{ env "NOMAD_PORT_postie_http" }},
            "meta": {
              "version": "2"
            },
            "connect": {
              "sidecar_service": {
                "port": {{ env "NOMAD_PORT_sidecar_ingress" }},
                "proxy": {
                  "local_service_address": "127.0.0.1",
                  "config": {
                    "envoy_prometheus_bind_addr": "0.0.0.0:{{ env "NOMAD_PORT_sidecar_metrics" }}"
                  },
                  "upstreams": [{
                    "destination_name": "upstream",
                    "local_bind_address": "127.0.0.1",
                    "local_bind_port": {{ env "NOMAD_PORT_sidecar_upstream" }}
                  }]
                }
              }
            }
          },
          {
            "name": "metrics",
            "ID": "metrics-{{ env "NOMAD_ALLOC_ID" }}",
            "port": {{ env "NOMAD_PORT_sidecar_metrics" }}
          }]
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