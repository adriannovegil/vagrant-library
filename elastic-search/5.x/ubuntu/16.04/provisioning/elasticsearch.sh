#!/bin/bash

set -o errexit

echo "Provisioning Elasticsearch"

# Install Elasticsearch
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-5.x.list
sudo apt-get update
sudo apt-get install -y elasticsearch
sudo service elasticsearch start

# Either of the next two lines is needed to be able to access "localhost:9200" from the host os
sudo echo "network.bind_host: 0" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "network.host: 0.0.0.0" >> /etc/elasticsearch/elasticsearch.yml

# Restart the server
sudo service elasticsearch stop
sudo service elasticsearch start

echo "Elasticsearch Successfully Provisioned"
