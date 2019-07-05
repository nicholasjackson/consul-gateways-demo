provider "kubernetes" {
  host                   = "${azurerm_kubernetes_cluster.demo.kube_config.0.host}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.demo.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.demo.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.demo.kube_config.0.cluster_ca_certificate)}"
}

# Resources for Helm tiller
/*
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
*/

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller.metadata[0].name
    namespace = "kube-system"
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name = "grafana-lb"
  }
  spec {
    selector = {
      app = "grafana"
    }

    port {
      port        = 80
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_service" "consul" {
  metadata {
    name = "consul-lb"
  }

  spec {
    selector = {
      app       = "consul"
      component = "server"
      release   = "consul"
    }

    port {
      name        = "api-ui"
      port        = 80
      target_port = 8500
    }

    port {
      name        = "api-api"
      port        = 8500
      target_port = 8500
    }

    port {
      name        = "serf-wan-tcp"
      port        = 8302
      target_port = 8302
      protocol    = "TCP"
    }

    port {
      name        = "consul-wan-rpc"
      port        = 8300
      target_port = 8300
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_service" "kubernetes" {
  metadata {
    name = "kubernetes-dash"
  }
  spec {
    selector = {
      k8s-app = "kubernetes-dashboard"
    }

    port {
      port        = 443
      target_port = 9090
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_service" "gateways" {
  metadata {
    name = "gateways"
  }
  spec {
    selector = {
      app       = "consul"
      component = "mesh-gateway"
    }

    port {
      port        = 443
      target_port = 443
    }

    type = "LoadBalancer"
  }
}
