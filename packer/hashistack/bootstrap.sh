#!/bin/bash
set -e

# Copy additional files.
cp /tmp/resources/envoy /usr/bin/envoy
cp /tmp/resources/nomad /usr/bin/nomad
cp /tmp/resources/consul /usr/bin/consul
cp /tmp/resources/consul /usr/bin/postie
cp /tmp/resources/nomad.service /etc/systemd/system/nomad.service
cp /tmp/resources/consul.service /etc/systemd/system/consul.service

mkdir /etc/nomad.d
mkdir /etc/consul.d

systemctl daemon-reload
systemctl enable nomad.service
systemctl enable consul.service