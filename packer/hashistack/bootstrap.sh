#!/bin/bash
set -e

mkdir -p /opt/cni/bin
curl -o /tmp/cni.tar.gz -L https://github.com/containernetworking/plugins/releases/download/v0.8.1/cni-plugins-linux-amd64-v0.8.1.tgz
tar -xzf /tmp/cni.tar.gz -C /opt/cni/bin

# Copy additional files.
cp /tmp/resources/envoy /usr/bin/envoy
cp /tmp/resources/nomad /usr/bin/nomad
cp /tmp/resources/consul /usr/bin/consul
cp /tmp/resources/postie /usr/bin/postie
cp /tmp/resources/nomad.service /etc/systemd/system/nomad.service
cp /tmp/resources/consul.service /etc/systemd/system/consul.service

mkdir /etc/nomad.d
mkdir /etc/consul.d

systemctl daemon-reload
systemctl enable nomad.service
systemctl enable consul.service