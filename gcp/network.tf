// A backend service that points at the Nomad servers instance group.
resource "google_compute_region_backend_service" "nomad" {
  name             = "nomad"
  protocol         = "TCP"
  timeout_sec      = 10
  session_affinity = "CLIENT_IP"

  backend {
    group = "${google_compute_instance_group_manager.server.instance_group}"
  }

  health_checks = ["${google_compute_health_check.nomad.self_link}"]
}

// A healthcheck that checks the Nomad http port.
resource "google_compute_health_check" "nomad" {
  name               = "nomad"
  check_interval_sec = 1
  timeout_sec        = 1

  tcp_health_check {
    port = "4646"
  }
}

// A forwarding rule so Google Cloud Build can reach the Nomad servers instance group.
resource "google_compute_forwarding_rule" "nomad" {
  name       = "server-forwarding-rule"
  backend_service = "${google_compute_region_backend_service.nomad.self_link}"
  load_balancing_scheme = "INTERNAL"
  ports = ["4646"]
}