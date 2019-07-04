output "loadbalancer_server" {
    value = google_compute_forwarding_rule.server.ip_address
}