provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.demo.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.demo.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.demo.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.demo.kube_config.0.cluster_ca_certificate)
  }

  service_account = "tiller"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.13.1"
}

resource "helm_release" "consul" {
  depends_on = [kubernetes_cluster_role_binding.tiller]

  name      = "consul"
  chart     = "${path.module}/helm-charts/consul-helm-gateways"
  namespace = "default"

  set {
    name  = "global.image"
    value = "nicholasjackson/consul:beta-3"
  }

  set {
    name  = "global.datacenter"
    value = "azure"
  }

  set {
    name  = "server.replicas"
    value = 1
  }

  set {
    name  = "server.bootstrapExpect"
    value = 1
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

  set {
    name  = "server.extraConfig"
    value = "\"{\\\"advertise_addr_wan\\\": \\\"${kubernetes_service.consul.load_balancer_ingress.0.ip}\\\", \\\"primary_datacenter\\\": \\\"google\\\"}\""
  }

  set {
    name  = "connectInject.centralConfig.enabled"
    value = true
  }

  set {
    name  = "connectInject.centralConfig.defaultProtocol"
    value = "http"
  }

  set {
    name  = "connectInject.centralConfig.proxyDefaults"
    value = "\"{\\\"envoy_prometheus_bind_addr\\\": \\\"0.0.0.0:9102\\\"}\""
  }

  set {
    name  = "connectInject.imageEnvoy"
    value = "envoyproxy/envoy:v1.10.0"
  }

  set {
    name  = "meshGateway.enabled"
    value = true
  }

  set {
    name  = "meshGateway.mode"
    value = "local"
  }

  set {
    name  = "meshGateway.wanAddress.useNodeIP"
    value = false
  }

  set {
    name  = "meshGateway.wanAddress.host"
    value = "${kubernetes_service.gateways.load_balancer_ingress.0.ip}"
  }

  set {
    name  = "meshGateway.imageEnvoy"
    value = "envoyproxy/envoy:v1.10.0"
  }
}
