output "azure_k8s_config" {
  value = module.k8s_azure.k8s_config
}

output "loadbalancer_grafana" {
  value = module.k8s_azure.loadbalancer_grafana
}

output "loadbalancer_consul" {
  value = module.k8s_azure.loadbalancer_consul
}

output "grafana_password" {
  value = module.k8s_azure.grafana_password
}

output "loadbalancer_gateway" {
  value = module.nomad_gcp.loadbalancer_gateway
}

output "loadbalancer_kubernetes" {
  value = module.k8s_azure.loadbalancer_kubernetes
}
