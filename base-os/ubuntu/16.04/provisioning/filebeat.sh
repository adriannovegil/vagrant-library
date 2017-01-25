#!/bin/bash

set -o errexit

echo "Provisioning Filebeat"

# Filebeat
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://packages.elastic.co/beats/apt stable main" |  sudo tee -a /etc/apt/sources.list.d/beats.list
sudo apt-get update
sudo apt-get install filebeat

sudo systemctl restart filebeat
sudo systemctl enable filebeat

sudo mkdir -p /etc/pki/tls/certs

echo "Filebeat Successfully Provisioned"
