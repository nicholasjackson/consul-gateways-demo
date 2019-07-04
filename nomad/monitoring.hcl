job "monitoring" {
  datacenters = ["google"]

  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
  }

  group "monitoring" {
    count = 1

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:v2.10.0"
        args = ["--config.file=/local/prometheus.yml"]

        network_mode = "host"
      }

      resources {
        cpu = 100
        memory = 1024

        network {
          mbits = 10
          port "http" {
            static = "9090"
          }
        }
      }

      service {
        name = "prometheus"
        port = "http"
      }

      template {
        data = <<EOH
---
scrape_configs:
- job_name: metrics
  scrape_interval: 10s
  consul_sd_configs:
  - server: {{ env "attr.unique.network.ip-address" }}:8500
    services: ['metrics']
  relabel_configs:
  - source_labels: ['__meta_consul_service']
    regex: 'nomad-client|nomad'
    action: drop
- job_name: nomad
  scrape_interval: 10s
  consul_sd_configs:
  - server: {{ env "attr.unique.network.ip-address" }}:8500
    services: ['nomad-client', 'nomad']
  relabel_configs:
  - source_labels: ['__meta_consul_tags']
    regex: '(.*)http(.*)'
    action: keep
  metrics_path: /v1/metrics
  params:
    format: ['prometheus']
        EOH
        destination   = "local/prometheus.yml"
      }
    }
  }
}