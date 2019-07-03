resource "kubernetes_deployment" "downstream" {
  depends_on = [helm_release.consul]

  metadata {
    name = "downstream"
    labels = {
      app = "downstream"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "downstream"
      }
    }

    template {
      metadata {
        labels = {
          app     = "downstream"
          version = "v0.1"
        }

        annotations = {
          "consul.hashicorp.com/connect-inject"            = "true"
          "consul.hashicorp.com/connect-service-protocol"  = "http"
          "consul.hashicorp.com/connect-service-upstreams" = "upstream:9001"
        }
      }

      spec {
        container {
          image = "nicholasjackson/postie:latest"
          name  = "downstream"

          command = ["postie"]
          args = [
            "--bind-address=0.0.0.0:9000",
            "--upstream-uri=http://localhost:9001"
          ]


          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "upstream" {
  depends_on = [helm_release.consul]

  metadata {
    name = "upstream"
    labels = {
      app = "upstream"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "upstream"
      }
    }

    template {
      metadata {
        labels = {
          app     = "upstream"
          version = "v0.1"
        }

        annotations = {
          "consul.hashicorp.com/connect-inject"           = "true"
          "consul.hashicorp.com/connect-service-protocol" = "http"
        }
      }

      spec {
        container {
          image = "nicholasjackson/postie:latest"
          name  = "upstream"

          command = ["postie"]
          args = [
            "--bind-address=localhost:9000",
            "--type=upstream",
          ]


          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "downstream" {
  metadata {
    name = "downstream-lb"
  }
  spec {
    selector = {
      app = kubernetes_deployment.downstream.metadata.0.labels.app
    }

    port {
      port        = 80
      target_port = 9000
    }

    type = "LoadBalancer"
  }
}
