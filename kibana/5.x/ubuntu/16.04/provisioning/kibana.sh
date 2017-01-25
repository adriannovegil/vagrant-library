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

# ------------------------------------------------------------------------------
# End of first part
# Load Kibana Dashboards
# ------------------------------------------------------------------------------

# Elastic provides several sample Kibana dashboards and Beats index patterns
# that can help you get started with Kibana. Although we won't use the
# dashboards in this tutorial, we'll load them anyway so we can use the Filebeat
# index pattern that it includes.
sudo curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.3.1.zip

# Install the unzip package with this command.
sudo apt-get -y install unzip

# Extract the contents of the archive.
unzip beats-dashboards-*.zip

# And load the sample dashboards, visualizations and Beats index patterns into
# Elasticsearch with these commands.
pushd ./beats-dashboards-1.3.1
./load.sh -url "http://10.0.3.10:9200"
popd

# These are the index patterns that we just loaded:
#   - packetbeat-*
#   - topbeat-*
#   - filebeat-*
#   - winlogbeat-*
# When we start using Kibana, we will select the Filebeat index pattern as our default.

# ------------------------------------------------------------------------------
# End of second part
# Load Filebeat Index Template in Elasticsearch
# ------------------------------------------------------------------------------

# Download the Filebeat index template to your home directory:
sudo curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json

# Load the template with this command:
curl -XPUT 'http://10.0.3.10:9200/_template/filebeat?pretty' -d@filebeat-index-template.json

echo "Kibana Successfully Provisioned"
