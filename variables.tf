# Azure
variable "client_id" {
  description = "Azure service principal client id used for kubernetes cluster"
}

variable "client_secret" {
  description = "Azure service principal client secret used for kubernetes cluster"
}

variable "gcp_project" {
  description = "GCP project to creat the nomad cluster in"
  default     = "consul-gateways-demo"
}
