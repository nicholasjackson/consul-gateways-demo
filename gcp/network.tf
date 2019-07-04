resource "google_compute_forwarding_rule" "server" {
  name       = "server-forwarding-rule"
  target     = "${google_compute_target_pool.server.self_link}"
  port_range = "1-65535"
}

resource "google_compute_forwarding_rule" "nomad" {
  name       = "nomad-forwarding-rule"
  target     = "${google_compute_target_pool.nomad.self_link}"
  port_range = "4646-4646"
  ip_address = "${google_compute_address.nomad.address}"
}

resource "google_compute_address" "nomad" {
    name = "nomad"
}

resource "google_compute_forwarding_rule" "consul" {
  name       = "consul-forwarding-rule"
  target     = "${google_compute_target_pool.consul.self_link}"
  port_range = "8500-8500"
  ip_address = "${google_compute_address.consul.address}"
}

resource "google_compute_address" "consul" {
    name = "consul"
}

resource "google_compute_forwarding_rule" "prometheus" {
  name       = "prometheus-forwarding-rule"
  target     = "${google_compute_target_pool.prometheus.self_link}"
  port_range = "9090-9090"
  ip_address = "${google_compute_address.prometheus.address}"
}

resource "google_compute_address" "prometheus" {
    name = "prometheus"
}