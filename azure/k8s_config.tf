provider "kubernetes" {
  host                   = "${azurerm_kubernetes_cluster.demo.kube_config.0.host}"
  username               = "${azurerm_kubernetes_cluster.demo.kube_config.0.username}"
  password               = "${azurerm_kubernetes_cluster.demo.kube_config.0.password}"
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
    name = "tiller"
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
    name      = "default"
    namespace = kubernetes_service_account.tiller.metadata[0].name
  }
}
