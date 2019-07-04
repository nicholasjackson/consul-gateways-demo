output "loadbalancer_server" {
    value = google_compute_global_forwarding_rule.frontend.ip_address
}