// // A backend service that points at the servers instance group.
// resource "google_compute_region_backend_service" "server" {
//   name             = "server"
//   protocol         = "TCP"
//   timeout_sec      = 10
//   session_affinity = "CLIENT_IP"

//   backend {
//     group = "${google_compute_instance_group_manager.server.instance_group}"
//   }

//   health_checks = ["${google_compute_health_check.nomad.name}", "${google_compute_health_check.consul.name}"]
// }

// // A forwarding rule so we can reach the servers instance group.
// resource "google_compute_forwarding_rule" "server" {
//   name       = "server-forwarding-rule"
//   backend_service = "${google_compute_region_backend_service.server.self_link}"
//   load_balancing_scheme = "EXTERNAL"
//   // target = "${google_compute_target_pool.server.self_link}"
//   ports = ["4646", "8500"]
// }

// // A healthcheck that checks the Nomad http port.
// resource "google_compute_health_check" "nomad" {
//   name               = "nomad"
//   check_interval_sec = 1
//   timeout_sec        = 1

//   tcp_health_check {
//     port = "4646"
//   }
// }


// // A healthcheck that checks the Consul http port.
// resource "google_compute_health_check" "consul" {
//   name               = "consul"
//   check_interval_sec = 1
//   timeout_sec        = 1

//   tcp_health_check {
//     port = "8500"
//   }
// }