#!/bin/bash

set -o errexit

echo "Provisioning Topbeat"

# Filebeat
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://packages.elastic.co/beats/apt stable main" |  sudo tee -a /etc/apt/sources.list.d/beats.list
sudo apt-get update
sudo apt-get install topbeat

sudo systemctl restart topbeat
sudo systemctl enable topbeat

sudo mkdir -p /etc/pki/tls/certs

echo "Topbeat Successfully Provisioned"
