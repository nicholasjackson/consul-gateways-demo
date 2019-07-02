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
  depends_on = [helm_release.grafana]

  metadata {
    name = "grafana"
  }
}

provider "grafana" {
  url  = "http://${kubernetes_service.grafana.load_balancer_ingress.0.ip}"
  auth = "admin:${data.kubernetes_secret.grafana.data.admin-password}"
}

resource "null_resource" "grafana_ready" {
  depends_on = [helm_release.grafana]

  provisioner "local-exec" {
    command = "until curl -f -s ${kubernetes_service.grafana.load_balancer_ingress.0.ip}; do; sleep 1; done"
  }
}

resource "grafana_data_source" "prometheus" {
  depends_on = [null_resource.grafana_ready]

  type       = "prometheus"
  name       = "prometheus-azure"
  url        = "http://prometheus-server:80/"
  is_default = true
}
