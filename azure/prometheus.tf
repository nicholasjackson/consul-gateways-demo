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
  url  = "http://grafana.${var.domain}"
  auth = data.kubernetes_secret.grafana.data.admin-password
}

resource "grafana_data_source" "prometheus" {
  depends_on = [helm_release.prometheus, helm_release.grafana]

  type = "prometheus"
  name = "prometheus-azure"
  url  = "http://prometheus-server:80/"
}
