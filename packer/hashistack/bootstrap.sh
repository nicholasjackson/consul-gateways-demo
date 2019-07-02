#!/bin/bash
set -e

# Install Nomad
curl -fsSL -o /tmp/nomad.zip https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
unzip -o -d /usr/bin/ /tmp/nomad.zip

# Copy additional files.
cp /tmp/resources/envoy /usr/bin/envoy
cp /tmp/resources/consul /usr/bin/consul
cp /tmp/resources/consul /usr/bin/postie
cp /tmp/resources/nomad.service /etc/systemd/system/nomad.service
cp /tmp/resources/consul.service /etc/systemd/system/consul.service

mkdir /etc/nomad.d
mkdir /etc/consul.d

systemctl daemon-reload
systemctl enable nomad.service
systemctl enable consul.service