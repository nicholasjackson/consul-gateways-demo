output "loadbalancer_server" {
    value = google_compute_global_forwarding_rule.frontend.ip_address
}

output "loadbalancer_gateway" {
    value = google_compute_forwarding_rule.gateway.ip_address
}