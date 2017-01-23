#!/bin/bash

set -o errexit

echo "Provisioning Kibana"

# Install Elasticsearch
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
sudo apt-get update
sudo apt-get install -y logstash

sudo systemctl daemon-reload
sudo systemctl enable logstash
sudo systemctl start logstash.service

echo "Kibana Successfully Provisioned"
