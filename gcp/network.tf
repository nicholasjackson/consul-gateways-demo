resource "google_compute_backend_service" "nomad" {
    name          = "nomad-backend-service"
    health_checks = ["${google_compute_health_check.nomad.self_link}"]

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
    
    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.nomad.self_link}"
    }
  }

  path_matcher {
    name            = "consul"
    default_service = "${google_compute_backend_service.consul.self_link}"
    
    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.consul.self_link}"
    }
  }

  path_matcher {
    name            = "prometheus"
    default_service = "${google_compute_backend_service.prometheus.self_link}"
    
    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.prometheus.self_link}"
    }
  }
}

resource "google_compute_global_address" "frontend" {
  name = "frontend-ip"
}


resource "google_compute_forwarding_rule" "frontend" {
  name       = "frontend-forwarding-rule"
  target     = "${google_compute_target_http_proxy.frontend.self_link}"
  port_range = "80-80"
  load_balancing_scheme = "EXTERNAL"
  ip_address = "${google_compute_global_address.frontend.self_link}"
}

//
//
//
//
//

resource "google_compute_forwarding_rule" "server" {
  name       = "server-forwarding-rule"
  target     = "${google_compute_target_pool.server.self_link}"
  port_range = "1-65535"
}