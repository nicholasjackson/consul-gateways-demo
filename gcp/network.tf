resource "google_compute_backend_service" "nomad" {
    name          = "nomad-backend-service"
    health_checks = ["${google_compute_health_check.nomad.self_link}"]
    port_name   = "nomad"

    backend {
        group = "${google_compute_instance_group_manager.server.instance_group}"
    }
}

resource "google_compute_health_check" "nomad" {
    name = "nomad-health-check"

    timeout_sec        = 10
    check_interval_sec = 10

    tcp_health_check {
        port = "4646"
    }
}

resource "google_compute_backend_service" "consul" {
    name          = "consul-backend-service"
    health_checks = ["${google_compute_health_check.consul.self_link}"]
    port_name   = "consul"

    backend {
        group = "${google_compute_instance_group_manager.server.instance_group}"
    }
}

resource "google_compute_health_check" "consul" {
    name = "consul-health-check"

    timeout_sec        = 10
    check_interval_sec = 10

    tcp_health_check {
        port = "8500"
    }
}

resource "google_compute_backend_service" "prometheus" {
    name          = "prometheus-backend-service"
    health_checks = ["${google_compute_health_check.prometheus.self_link}"]
    port_name   = "prometheus"

    backend {
        group = "${google_compute_instance_group_manager.server.instance_group}"
    }
}

resource "google_compute_health_check" "prometheus" {
    name = "prometheus-health-check"

    timeout_sec        = 10
    check_interval_sec = 10

    tcp_health_check {
        port = "9090"
    }
}

resource "google_compute_target_http_proxy" "frontend" {
  name        = "frontend-proxy"
  url_map     = "${google_compute_url_map.frontend.self_link}"
}

resource "google_compute_url_map" "frontend" {
    name        = "frontend-url-map"
    default_service = "${google_compute_backend_service.prometheus.self_link}"

    host_rule {
        hosts        = ["nomad.google.demo.gs"]
        path_matcher = "nomad"
    }

    host_rule {
        hosts        = ["consul.google.demo.gs"]
        path_matcher = "consul"
    }

    host_rule {
        hosts        = ["prometheus.google.demo.gs"]
        path_matcher = "prometheus"
    }

    path_matcher {
        name            = "nomad"
        default_service = "${google_compute_backend_service.nomad.self_link}"
    }

    path_matcher {
        name            = "consul"
        default_service = "${google_compute_backend_service.consul.self_link}"
    }

    path_matcher {
        name            = "prometheus"
        default_service = "${google_compute_backend_service.prometheus.self_link}"
    }
}

resource "google_compute_global_address" "frontend" {
  name = "frontend-ip"
}


resource "google_compute_global_forwarding_rule" "frontend" {
  name       = "frontend"
  target     = "${google_compute_target_http_proxy.frontend.self_link}"
  port_range = "80"
  ip_address = "${google_compute_global_address.frontend.address}"
}

// resource "google_compute_global_forwarding_rule" "consul-federation" {
//   name       = "consul-federation"
//   target     = "${google_compute_target_pool.consul.self_link}"
//   port_range = "8300-8302"
//   ip_address = "${google_compute_global_address.frontend.address}"
// }

// resource "google_compute_target_tcp_proxy" "consul-federation" {
//   name            = "consul-federation"
//   backend_service = "${google_compute_backend_service.consul-federation.self_link}"
// }

// resource "google_compute_backend_service" "consul-federation" {
//   name          = "consul-federation"
//   protocol      = "TCP"
//   timeout_sec   = 10

//   health_checks = ["${google_compute_health_check.consul-federation.self_link}"]
// }

// resource "google_compute_health_check" "consul-federation" {
//   name               = "consul-federation"
//   timeout_sec        = 10
//   check_interval_sec = 10

//   tcp_health_check {
//     port = "8300"
//   }
// }