#!/bin/bash
IP=$(getent ahosts $HOSTNAME | head -n 1 | cut -d ' ' -f 1)
WAN_IP=$(curl -H "Metadata-Flavor: Google" http://metadata/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

# Set up credential helpers for Google Container Registry.
mkdir -p /etc/docker
cat <<EOF > /etc/docker/config.json
{
  "credHelpers": {
    "gcr.io": "gcr"
  }
}
EOF

# Configure Consul.
mkdir -p /etc/consul.d
cat <<EOF > /etc/consul.d/server.hcl
log_level = "DEBUG"
data_dir = "/tmp/consul"
datacenter = "google"

enable_central_service_config = true
config_entries {
  bootstrap {
    kind = "proxy-defaults"
    name = "global"

    config {
      envoy_prometheus_bind_addr = "0.0.0.0:9102"
    }

    MeshGateway {
      Mode = "local"
    }
  }
}

server = true
bootstrap_expect = 3
retry_join = ["provider=gce tag_value=server"]
retry_join_wan = ["consul.azure.demo.gs"]

bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
advertise_addr = "$IP"
advertise_addr_wan = "$WAN_IP"

ports {
  grpc = 8502
}

connect {
  enabled = true
}

ui = true
EOF

systemctl restart consul

# Configure Nomad.
mkdir -p /etc/nomad.d
cat <<EOF > /etc/nomad.d/server.hcl
log_level = "DEBUG"
data_dir = "/tmp/nomad"
datacenter = "google"

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics = true
  prometheus_metrics = true
}

server {
  enabled = true
  bootstrap_expect = 3
}

client {
  enabled = true
  options {
    "docker.auth.config" = "/etc/docker/config.json"
  }
}

consul {
  address = "localhost:8500"

  server_service_name = "nomad"
  client_service_name = "nomad-client"

  auto_advertise = true

  server_auto_join = true
  client_auto_join = true
}
EOF

systemctl restart nomad

