// A backend service that points at the Nomad servers instance group.
resource "google_compute_region_backend_service" "nomad" {
  name             = "nomad"
  protocol         = "TCP"
  timeout_sec      = 10
  session_affinity = "CLIENT_IP"

  backend {
    group = "${google_compute_instance_group_manager.nomad.instance_group}"
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

// A forwarding rule so we can reach the Nomad servers instance group.
resource "google_compute_forwarding_rule" "nomad" {
  name       = "nomad-forwarding-rule"
  backend_service = "${google_compute_region_backend_service.nomad.self_link}"
  // load_balancing_scheme = "INTERNAL"
  ports = ["4646"]
}

// A backend service that points at the Consul servers instance group.
resource "google_compute_region_backend_service" "consul" {
  name             = "consul"
  protocol         = "TCP"
  timeout_sec      = 10
  session_affinity = "CLIENT_IP"

  backend {
    group = "${google_compute_instance_group_manager.consul.instance_group}"
  }

  health_checks = ["${google_compute_health_check.consul.self_link}"]
}

// A healthcheck that checks the Consul http port.
resource "google_compute_health_check" "consul" {
  name               = "consul"
  check_interval_sec = 1
  timeout_sec        = 1

  tcp_health_check {
    port = "8500"
  }
}

// A forwarding rule so we can reach the Consul servers instance group.
resource "google_compute_forwarding_rule" "consul" {
  name       = "consul-forwarding-rule"
  backend_service = "${google_compute_region_backend_service.consul.self_link}"
  // load_balancing_scheme = "INTERNAL"
  ports = ["8500"]
}