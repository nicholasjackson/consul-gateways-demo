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

  values = [
    "${file("${path.module}/grafana_values.yml")}"
  ]
}

data "kubernetes_secret" "grafana" {
  depends_on = [helm_release.grafana]

  metadata {
    name = "grafana"
  }
}
