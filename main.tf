# Create a Kubernetes cluster in Azure and deploy the application to it
module "k8s_azure" {
  source = "./azure"

  client_id     = var.client_id
  client_secret = var.client_secret
}
