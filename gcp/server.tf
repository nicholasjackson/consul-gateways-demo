// Instance group manager for the Nomad servers.
resource "google_compute_instance_group_manager" "server" {
  name               = "server-group-manager"
  instance_template  = "${google_compute_instance_template.server.self_link}"
  base_instance_name = "server"
  zone               = "${var.instance-zone}"
  target_size        = "${var.instance-count}"

  target_pools       = ["${google_compute_target_pool.gateway.self_link}"]

  named_port {
    name = "nomad"
    port = 4646
  }

  named_port {
    name = "consul"
    port = 8500
  }

  named_port {
    name = "prometheus"
    port = 9090
  }
}

resource "google_compute_target_pool" "gateway" {
  name = "gateway"
}

// The instance template for the Nomad servers.
resource "google_compute_instance_template" "server" {
  name_prefix  = "server-template-"
  description = "This template is used for server instances."

  tags = ["nomad", "consul", "server"]

  labels = {
    environment = "dev"
  }

  instance_description = "server instance"
  machine_type         = "${var.instance-type}"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "${var.project}/hashistack-0-2-4"
    auto_delete  = true
    boot         = true
  }

  metadata_startup_script = "${data.template_file.metadata_startup_script.rendered}"

  network_interface {
    network = "default"

    access_config {}
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

// The startup script of the Nomad servers.
data "template_file" "metadata_startup_script" {
    template = "${file("${path.module}/files/bootstrap.sh")}"
}