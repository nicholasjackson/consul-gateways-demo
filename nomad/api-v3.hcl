job "api-v3" {
  datacenters = ["google"]
  type = "service"

  group "api" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        // static = 9090
        // to = 9090
        // static = 9090
      }
      port "metrics" {}
    }

    service {
      name = "api"
      tags = ["v3"]
      port = 9090

      meta {
        version = "3"
      }

      connect {
        sidecar_service {
          proxy {
            config {
              protocol = "http"
              envoy_prometheus_bind_addr = "0.0.0.0:9201"
            }
          }
        }
      }
    }

    service {
      name = "metrics"
      tags = ["v3"]
      port = 9201
    }

    task "postie" {
      driver = "raw_exec"

      config {
        command = "postie"
        args = [
          "--bind-address=127.0.0.1:9090",
          "--type=upstream",
          "--upstream-rate-limit", "70"
        ]
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}
