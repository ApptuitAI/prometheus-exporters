# Elasticsearch Metrics Exporter [![Build Status](https://www.travis-ci.org/ApptuitAI/prometheus-exporters.svg?branch=master)](https://www.travis-ci.org/ApptuitAI/prometheus-exporters)

Prometheus Elasticsearch metrics exporter for reporting metrics to Apptuit.ai

### Installation

Elasticsearch Exporter is available via debian & yum repositories.

#### Non-Interactive installation

This is the default mode of installation. In this mode, the installer script assumes that you have an elasticsearch
cluster up and running. The installer reads the following environment variable(s) for the inputs it needs. Please be 
sure to set them up with the appropriate value(s) before invoking the commands below.

###### Default configuration
If your elasticsearch server is running on localhost:9200 and does *not* need any authentication, you can install the exporter using:
```bash
# Install using CURL
bash -c "$(curl -Ls https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/elasticsearch_exporter/install.sh)"

# OR install using WGET
bash -c "$(wget -qO- https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/elasticsearch_exporter/install.sh)"
```

###### Advanced configuration
If your ES is running at an address other than `localhost:9200` or if it needs authentication, you can use the ES_URL environment variable to configure the connection details of the ES server.

The format for the ES_URL environment variable is `ES_URL="http://<es_user>:<es_user_password>@<es_host>:<es_port>"`. Please *note the password (and username) must be urlencoded*.

```bash
# Install using CURL
ES_URL="http://<es_user>:<es_user_password>@<es_host>:<es_port>" bash -c "$(curl -Ls https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/elasticsearch_exporter/install.sh)"

# OR install using WGET
ES_URL="http://<es_user>:<es_user_password>@<es_host>:<es_port>" bash -c "$(wget -qO- https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/elasticsearch_exporter/install.sh)"
```

You can change ES_URL anytime after installation by editing 
the value of the parameter '-es.uri' in the environment variable EXPORTER_FLAGS in /etc/default/elasticsearch-exporter.

##### Interactive installation

This mode of installation takes inputs interactively from the terminal to configure the exporter. 

For interactive installation using curl, please invoke...
 
```
bash -c "$(curl -Ls https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/elasticsearch_exporter/install.sh)" --interactive
``` 

For interactive installation using wget, please invoke...

```
bash -c "$(wget -qO- https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/elasticsearch_exporter/install.sh)" --interactive
```
This interactive process takes you through prompts for setting up your ES_URL (with/without user credentials) in 
the exporter config.
 
