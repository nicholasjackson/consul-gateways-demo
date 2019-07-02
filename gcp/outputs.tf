output "loadbalancer_nomad" {
    value = google_compute_forwarding_rule.server.ip_address
}