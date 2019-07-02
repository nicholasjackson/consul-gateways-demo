provider "dnsimple" {
}

# Create a record
resource "dnsimple_record" "grafana" {
  domain = "demo.gs"
  name   = "grafana.azure"
  type   = "A"
  ttl    = 3600
  value  = module.k8s_azure.loadbalancer_grafana
}

resource "dnsimple_record" "google" {
  domain  = "demo.gs"
  name    = "google"
  type    = "A"
  ttl     = 3600
  value   = module.nomad_gcp.loadbalancer_nomad
}