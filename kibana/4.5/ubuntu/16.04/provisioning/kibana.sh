#!/bin/bash

set -o errexit

echo "Provisioning Kibana"

# Install Kibana
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb http://packages.elastic.co/kibana/4.5/debian stable main" | sudo tee -a /etc/apt/sources.list.d/kibana.list
sudo apt-get update
sudo apt-get install -y kibana

# Either of the next two lines is needed to be able to access "localhost:9200" from the host os
sudo echo 'server.host: "192.168.0.13"' >> /opt/kibana/config/kibana.yml

sudo systemctl daemon-reload
sudo systemctl enable kibana
sudo systemctl start kibana

echo "Kibana Successfully Provisioned"
