job "gateway" {
  datacenters = ["google"]

  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
  }

    group "gateways" {
        count = 1

        constraint {
        operator  = "distinct_hosts"
        value     = "true"
        }

        task "gateway" {
        driver = "exec"

        config {
            command = "consul"
            args    = [
            "connect", "envoy",
            "-mesh-gateway",
            "-register",
            "-address", ":20443",
            "-wan-address", "35.233.51.3:20443",
            "--",
            "-l", "debug"
            ]
        }

        env {
            PATH="${PATH}:${NOMAD_TASK_DIR}"
        }

        resources {
            network {
            port "ingress" {}
            port "metrics" {}
            }
        }
        }
    }
}