resource "helm_release" "prometheus" {
  depends_on = [kubernetes_cluster_role_binding.tiller]

  name      = "prometheus"
  chart     = "stable/prometheus"
  namespace = "default"
}

resource "helm_release" "grafana" {
  depends_on = [kubernetes_cluster_role_binding.tiller]

  name      = "grafana"
  chart     = "stable/grafana"
  namespace = "default"
}


data "kubernetes_secret" "grafana" {
  metadata {
    name = "grafana"
  }
}

provider "grafana" {
  url  = "http://${kubernetes_service.grafana.load_balancer_ingress.0.ip}"
  auth = "admin:${data.kubernetes_secret.grafana.data.admin-password}"
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "prometheus-azure"
  url        = "http://prometheus-server:80/"
  is_default = true
}
