provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.demo.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.demo.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.demo.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.demo.kube_config.0.cluster_ca_certificate)
  }

  install_tiller  = true
  service_account = "tiller"
}

resource "helm_release" "consul" {
  name      = "consul"
  chart     = "${path.module}/helm-charts/consul-helm"
  namespace = "default"

  set {
    name  = "global.image"
    value = "consul:1.5.2"
  }

  set {
    name  = "server.replicas"
    value = 3
  }

  set {
    name  = "server.bootstrapExpect"
    value = 3
  }

  set {
    name  = "client.grpc"
    value = true
  }

  set {
    name  = "connectInject.enabled"
    value = true
  }

  set {
    name  = "centralConfig.enabled"
    value = true
  }
}
