resource "kubernetes_deployment" "web" {
  depends_on = [helm_release.consul]

  metadata {
    name = "web"
    labels = {
      app = "web"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "web"
      }
    }

    template {
      metadata {
        labels = {
          app     = "web"
          version = "v0.1.8"
        }

        annotations = {
          "consul.hashicorp.com/connect-inject"            = "true"
          "consul.hashicorp.com/connect-service-protocol"  = "http"
          "consul.hashicorp.com/connect-service-upstreams" = "web:9001:google"
          "prometheus.io/scrape" : "true"
          "prometheus.io/port" : "9102"
        }
      }

      spec {
        container {
          image = "nicholasjackson/postie:latest"
          name  = "web"

          command = ["postie"]
          args = [
            "--bind-address=0.0.0.0:9000",
            "--upstream-uri=http://localhost:9001"
          ]

          port {
            name           = "http"
            container_port = 9000
          }


          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "0.1"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "api" {
  depends_on = [helm_release.consul]

  metadata {
    name = "api"
    labels = {
      app = "api"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "api"
      }
    }

    template {
      metadata {
        labels = {
          app     = "api"
          version = "v0.1.8"
        }

        annotations = {
          "consul.hashicorp.com/connect-inject"           = "true"
          "consul.hashicorp.com/connect-service-protocol" = "http"
          "prometheus.io/scrape" : "true"
          "prometheus.io/port" : "9102"
        }
      }

      spec {
        container {
          image = "nicholasjackson/postie:latest"
          name  = "api"

          command = ["postie"]
          args = [
            "--bind-address=localhost:9000",
            "--type=upstream",
          ]

          port {
            name           = "http"
            container_port = 9000
          }


          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "0.1"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "httperf" {
  // depends_on = [helm_release.consul]

  metadata {
    name = "httperf"
    labels = {
      app = "httperf"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "httperf"
      }
    }

    template {
      metadata {
        labels = {
          app     = "httperf"
          version = "v0.1.2"
        }
      }

      spec {
        container {
          image = "quay.io/alaska/httperf"
          name  = "httperf"

          command = ["httperf"]
          args = [
            "--server", "${kubernetes_service.web.load_balancer_ingress.0.ip}",
            "--port", "80",
            "--timeout", "1",
            "--num-conns", "100000",
            "--rate", "100",
          ]


          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "0.1"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name = "web-lb"
  }
  spec {
    selector = {
      app = kubernetes_deployment.web.metadata.0.labels.app
    }

    port {
      port        = 80
      target_port = 9000
    }

    type = "LoadBalancer"
  }
}
