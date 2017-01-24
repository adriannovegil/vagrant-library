#!/bin/bash

set -o errexit

echo "Provisioning Nginx"

# Install Nginx
sudo apt-get -y install nginx apache2-utils

# Add the user to the Kibana Dashboard
# http://devopspy.com/devops/install-elk-stack-centos-7-logs-analytics/
sudo htpasswd -bc /etc/nginx/htpasswd.users kibanaadmin kibanaadmin

# Config the site.
sudo cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80;

    server_name example.com;

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Now Restart the server
sudo systemctl restart nginx

# If you followed the initial server setup guide for 16.04, you have a UFW
# firewall enabled. To allow connections to Nginx, we can adjust the rules by
# typing:
sudo ufw allow 'Nginx Full'

echo "Nginx Successfully Provisioned"
