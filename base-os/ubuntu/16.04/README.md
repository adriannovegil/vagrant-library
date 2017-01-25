## Configure Filebeat

Now we will configure Filebeat to connect to Logstash on our ELK Server. This section will step you through modifying the example configuration file that comes with Filebeat. When you complete the steps, you should have a file that looks something like this.

On the Client Server, create and edit Filebeat configuration file:

sudo nano /etc/filebeat/filebeat.yml
Note
Filebeat's configuration file is in YAML format, which means that indentation is very important! Be sure to use the same number of spaces that are indicated in these instructions.
Near the top of the file, you will see the prospectors section, which is where you can define prospectors that specify which log files should be shipped and how they should be handled. Each prospector is indicated by the - character.

We'll modify the existing prospector to send syslog and auth.log to Logstash. Under paths, comment out the - /var/log/*.log file. This will prevent Filebeat from sending every .log in that directory to Logstash. Then add new entries for syslog and auth.log. It should look something like this when you're done:

/etc/filebeat/filebeat.yml excerpt 1 of 5
...
      paths:
        - /var/log/auth.log
        - /var/log/syslog
       # - /var/log/*.log
...
Then find the line that specifies document_type:, uncomment it and change its value to "syslog". It should look like this after the modification:

/etc/filebeat/filebeat.yml excerpt 2 of 5
...
      document_type: syslog
...
This specifies that the logs in this prospector are of type syslog (which is the type that our Logstash filter is looking for).

If you want to send other files to your ELK server, or make any changes to how Filebeat handles your logs, feel free to modify or add prospector entries.

Next, under the output section, find the line that says elasticsearch:, which indicates the Elasticsearch output section (which we are not going to use). Delete or comment out the entire Elasticsearch output section (up to the line that says #logstash:).

Find the commented out Logstash output section, indicated by the line that says #logstash:, and uncomment it by deleting the preceding #. In this section, uncomment the hosts: ["localhost:5044"] line. Change localhost to the private IP address (or hostname, if you went with that option) of your ELK server:

/etc/filebeat/filebeat.yml excerpt 3 of 5
  ### Logstash as output
  logstash:
    # The Logstash hosts
    hosts: ["ELK_server_private_IP:5044"]
This configures Filebeat to connect to Logstash on your ELK Server at port 5044 (the port that we specified a Logstash input for earlier).

Directly under the hosts entry, and with the same indentation, add this line:

/etc/filebeat/filebeat.yml excerpt 4 of 5
  ### Logstash as output
  logstash:
    # The Logstash hosts
    hosts: ["ELK_server_private_IP:5044"]
    bulk_max_size: 1024
Next, find the tls section, and uncomment it. Then uncomment the line that specifies certificate_authorities, and change its value to ["/etc/pki/tls/certs/logstash-forwarder.crt"]. It should look something like this:

/etc/filebeat/filebeat.yml excerpt 5 of 5
...
    tls:
      # List of root certificates for HTTPS server verifications
      certificate_authorities: ["/etc/pki/tls/certs/logstash-forwarder.crt"]
This configures Filebeat to use the SSL certificate that we created on the ELK Server.

Save and quit.

Now restart Filebeat to put our changes into place:

sudo systemctl restart filebeat
sudo systemctl enable filebeat
Again, if you're not sure if your Filebeat configuration is correct, compare it against this example Filebeat configuration.

Now Filebeat is sending syslog and auth.log to Logstash on your ELK server! Repeat this section for all of the other servers that you wish to gather logs for.


##Test Filebeat Installation

If your ELK stack is setup properly, Filebeat (on your client server) should be shipping your logs to Logstash on your ELK server. Logstash should be loading the Filebeat data into Elasticsearch using the indexes we imported earlier.

On your ELK Server, verify that Elasticsearch is indeed receiving the data by querying for the Filebeat index with this command:

```
 $curl -XGET 'http://localhost:9200/filebeat-*/_search?pretty'
```

##Test Topbeat Installation

If your ELK stack is setup properly, Topbeat (on your client server) should be shipping your logs to Logstash on your ELK server. Logstash should be loading the Topbeat data into Elasticsearch using the indexes we imported earlier.

On your ELK Server, verify that Elasticsearch is indeed receiving the data by querying for the Topbeat index with this command:

```
 $curl -XGET 'http://localhost:9200/topbeat-*/_search?pretty'
```
