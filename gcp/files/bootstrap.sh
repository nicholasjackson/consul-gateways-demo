#!/bin/bash
IP=$(getent ahosts $HOSTNAME | head -n 1 | cut -d ' ' -f 1)

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

server = true
bootstrap_expect = 3
retry_join = ["provider=gce tag_value=server"]

bind_addr = "$IP"

ui = true
EOF

systemctl restart consul

# Configure Nomad.
mkdir -p /etc/nomad.d
cat <<EOF > /etc/nomad.d/server.hcl
log_level = "DEBUG"
data_dir = "/tmp/nomad"

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

