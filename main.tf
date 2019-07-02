terraform {
  backend "atlas" {
    name = "niccorp/consul-gateways-demo"
  }
}


# Create a Kubernetes cluster in Azure and deploy the application to it
module "k8s_azure" {
  source = "./azure"

  client_id     = var.client_id
  client_secret = var.client_secret
}

# Create a Nomad cluster in GCP and deploy the application to it
module "nomad_gcp" {
  source = "./gcp"

  project   = var.gcp_project
}