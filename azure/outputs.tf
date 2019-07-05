output "k8s_config" {
  value = azurerm_kubernetes_cluster.demo.kube_config_raw
}

output "loadbalancer_grafana" {
  value = kubernetes_service.grafana.load_balancer_ingress.0.ip
}

output "loadbalancer_consul" {
  value = kubernetes_service.consul.load_balancer_ingress.0.ip
}

output "loadbalancer_gateway" {
  value = kubernetes_service.consul.load_balancer_ingress.0.ip
}

output "loadbalancer_kubernetes" {
  value = kubernetes_service.kubernetes.load_balancer_ingress.0.ip
}

output "grafana_password" {
  value = data.kubernetes_secret.grafana.data.admin-password
}
