output "k8s_config" {
  value = azurerm_kubernetes_cluster.demo.kube_config_raw
}

output "loadbalancer_grafana" {
  value = kubernetes_service.grafana.load_balancer_ingress.0.ip
}
