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

    path_matcher {
        name            = "nomad"
        default_service = "${google_compute_backend_service.nomad.self_link}"
    }


    host_rule {
        hosts        = ["consul.google.demo.gs"]
        path_matcher = "consul"
    }

    path_matcher {
        name            = "consul"
        default_service = "${google_compute_backend_service.consul.self_link}"
    }

    host_rule {
        hosts        = ["prometheus.google.demo.gs"]
        path_matcher = "prometheus"
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

resource "google_compute_address" "gateway" {
  name = "gateway-ip"
}

resource "google_compute_forwarding_rule" "gateway" {
  name       = "gateway"
  target     = "${google_compute_target_pool.gateway.self_link}"
  port_range = "1-65535"
  ip_address = "${google_compute_address.gateway.address}"
}