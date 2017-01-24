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
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
pushd ./beats-dashboards-1.3.1
./load.sh
popd
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

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
curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json

# Load the template with this command:
curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat-index-template.json

echo "Elasticsearch Successfully Provisioned"
