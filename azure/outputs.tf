output "k8s_config" {
  value = azurerm_kubernetes_cluster.demo.kube_config_raw
}
