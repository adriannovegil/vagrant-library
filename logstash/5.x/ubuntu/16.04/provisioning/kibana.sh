#!/bin/bash

set -o errexit

echo "Provisioning Logstash"

# Install Elasticsearch
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
sudo apt-get update
sudo apt-get install -y logstash

sudo systemctl daemon-reload
sudo systemctl enable logstash
sudo systemctl start logstash.service

# ------------------------------------------------------------------------------
# End of first part
# ------------------------------------------------------------------------------

# Generate SSL Certificates
# Since we are going to use Filebeat to ship logs from our Client Servers to our
# Logstash Server, we need to create an SSL certificate and key pair. The
# certificate is used by Filebeat to verify the identity of Logstash Server.
# Create the directories that will store the certificate and private key with
# the following commands:
sudo mkdir -p /etc/pki/tls/certs
sudo mkdir /etc/pki/tls/private

# subjectAltName = IP: ELK_server_private_IP

# Now generate the SSL certificate and private key in the appropriate locations
# (/etc/pki/tls/...), with the following commands:
sudo openssl req \
  -config /etc/ssl/openssl.cnf \
  -x509 \
  -days 3650 \
  -batch \
  -nodes \
  -newkey rsa:2048 \
  -keyout /etc/pki/tls/private/logstash-forwarder.key \
  -out /etc/pki/tls/certs/logstash-forwarder.crt

# Let's create a configuration file called 02-beats-input.conf and set up our
# "filebeat" input:
sudo cat > /etc/logstash/conf.d/02-beats-input.conf <<'EOF'
input {
  beats {
    port => 5044
    ssl => true
    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
    ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
  }
}
EOF

# If you followed the Ubuntu 16.04 initial server setup guide, you will have a
# UFW firewall configured. To allow Logstash to receive connections on port
# 5044, we need to open that port:
sudo ufw allow 5044

# Now let's create a configuration file called 10-syslog-filter.conf, where we
# will add a filter for syslog messages:
sudo cat > /etc/logstash/conf.d/10-syslog-filter.conf <<'EOF'
filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
      add_field => [ "received_at", "%{@timestamp}" ]
      add_field => [ "received_from", "%{host}" ]
    }
    syslog_pri { }
    date {
      match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
}
EOF

# Lastly, we will create a configuration file called
# 30-elasticsearch-output.conf:
sudo cat > /etc/logstash/conf.d/30-elasticsearch-output.conf <<'EOF'
output {
  elasticsearch {
    hosts => ["localhost:9200"]
    sniffing => true
    manage_template => false
    index => "%{[@metadata][beat]}-%{+YYYY.MM.dd}"
    document_type => "%{[@metadata][type]}"
  }
}
EOF

# Restart Logstash, and enable it, to put our configuration changes into effect:
sudo systemctl restart logstash
sudo systemctl enable logstash

echo "Logstash Successfully Provisioned"
