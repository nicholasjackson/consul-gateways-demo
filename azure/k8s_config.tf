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
  depends_on = [helm_release.grafana, helm_release.prometheus]
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
  depends_on = [helm_release.consul]

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
      port        = 80
      target_port = 8500
    }

    type = "LoadBalancer"
  }
}
