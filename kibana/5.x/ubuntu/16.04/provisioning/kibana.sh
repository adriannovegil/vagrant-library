#!/bin/bash

set -o errexit

echo "Provisioning Kibana"

# Install Kibana
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
sudo apt-get update
sudo apt-get install -y kibana

# Either of the next two lines is needed to be able to access "localhost:9200" from the host os
# sudo echo 'server.host: "0.0.0.0"' >> /etc/kibana/kibana.yml
sudo echo 'server.host: "localhost"' >> /etc/kibana/kibana.yml
sudo echo 'elasticsearch.url: "http://10.0.3.10:9200"' >> /etc/kibana/kibana.yml

sudo systemctl daemon-reload
sudo systemctl enable kibana
sudo systemctl start kibana

echo "Kibana Successfully Provisioned"
