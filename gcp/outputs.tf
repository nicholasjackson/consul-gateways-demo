output "loadbalancer_server" {
    value = google_compute_forwarding_rule.server.ip_address
}

output "loadbalancer_nomad" {
    value = google_compute_forwarding_rule.nomad.ip_address
}

output "loadbalancer_consul" {
    value = google_compute_forwarding_rule.consul.ip_address
}

output "loadbalancer_prometheus" {
    value = google_compute_forwarding_rule.prometheus.ip_address
}