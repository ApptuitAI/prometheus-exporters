# Elasticsearch Metrics Exporter [![Build Status](https://www.travis-ci.org/ApptuitAI/prometheus-exporters.svg?branch=master)](https://www.travis-ci.org/ApptuitAI/prometheus-exporters)

Prometheus Elasticsearch metrics exporter for reporting metrics to Apptuit.ai

### Installation

Elasticsearch Exporter is available via debian & yum repositories.

#### Non-Interactive installation

This is the default mode of installation. In this mode, the installer script assumes that you have an elasticsearch
cluster up and running. The installer reads the following environment variable(s) for the inputs it needs. Please be 
sure to set them up with the appropriate value(s) before invoking the commands below.

For default non-interactive install using curl, please use...

```bash
ES_URL="http://<es_user>:<es_user_password>@<es_host>:<es_port>" bash -c "$(curl -Ls https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/elasticsearch_exporter/install.sh)"
```

For non-interactive install using wget please use...

```bash
ES_URL="http://<es_user>:<es_user_password>@<es_host>:<es_port>" bash -c "$(wget -qO- https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/elasticsearch_exporter/install.sh)"
```

In absence of the ES_URL environment variable, the installer script assumes a default one - 
"http://localhost:9200". You can change this anytime after installation by editing 
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
 