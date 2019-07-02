output "azure_k8s_config" {
  value = module.k8s_azure.k8s_config
}

output "loadbalancer" {
  value = module.k8s_azure.loadbalancer_grafana
}

output "grafana_password" {
  value = module.k8s_azure.grafana_password
}
