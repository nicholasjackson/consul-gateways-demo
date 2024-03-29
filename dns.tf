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

resource "dnsimple_record" "consul" {
  domain = "demo.gs"
  name   = "consul.azure"
  type   = "A"
  ttl    = 3600
  value  = module.k8s_azure.loadbalancer_consul
}

resource "dnsimple_record" "consul_gateway" {
  domain = "demo.gs"
  name   = "gateway.azure"
  type   = "A"
  ttl    = 3600
  value  = module.k8s_azure.loadbalancer_gateway
}

resource "dnsimple_record" "kubernetes_dash" {
  domain = "demo.gs"
  name   = "k8s.azure"
  type   = "A"
  ttl    = 3600
  value  = module.k8s_azure.loadbalancer_kubernetes
}

resource "dnsimple_record" "google" {
  domain = "demo.gs"
  name   = "google"
  type   = "A"
  ttl    = 3600
  value  = module.nomad_gcp.loadbalancer_server
}

resource "dnsimple_record" "google_consul" {
  domain = "demo.gs"
  name   = "consul.google"
  type   = "A"
  ttl    = 3600
  value  = module.nomad_gcp.loadbalancer_server
}

resource "dnsimple_record" "google_nomad" {
  domain = "demo.gs"
  name   = "nomad.google"
  type   = "A"
  ttl    = 3600
  value  = module.nomad_gcp.loadbalancer_server
}

resource "dnsimple_record" "google_prometheus" {
  domain = "demo.gs"
  name   = "prometheus.google"
  type   = "A"
  ttl    = 3600
  value  = module.nomad_gcp.loadbalancer_server
}
