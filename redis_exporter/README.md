# Redis Metrics Exporter [![Build Status](https://travis-ci.com/ApptuitAI/prometheus-exporters.svg?branch=master)](https://travis-ci.com/ApptuitAI/prometheus-exporters)

Prometheus Redis metrics exporter for reporting metrics to Apptuit.ai

### Installation

Redis Exporter is available via debian & yum repositories. 

#### Non-Interactive installation

This is the default mode of installation. In this mode, the installer script assumes that you have a Redis  
instance / cluster up and running and have already setup a password to access the cluster metrics.
The installer reads the following environment variable(s) for the inputs it needs. Please be sure to set them up with 
the appropriate value(s) before invoking the commands below.

For default non-interactive install using curl, please use...

```bash
REDIS_ADDR="redis://<redis_host>:<redis_port>" REDIS_ALIAS="<redis_alias_tag_value>" REDIS_PASSWORD="<redis_password>" bash -c "$(curl -Ls https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/redis_exporter/install.sh)"
```

For non-interactive install using wget please use...

```bash
REDIS_ADDR="redis://<redis_host>:<redis_port>" REDIS_ALIAS="<redis_alias_tag_value>" REDIS_PASSWORD="<redis_password>" bash -c "$(wget -qO- https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/redis_exporter/install.sh)"
```

In absence of any of these environment variable(s), the installer script assumes default values for each of these 
as below...

* REDIS_ADDR="redis://localhost:6379"
* REDIS_ALIAS="$(hostname -s)"
* REDIS_PASSWORD="" 

You can change these values anytime after installation by editing values for 
any of these environment variables in /etc/default/redis-exporter.

##### Interactive installation

This mode of installation takes inputs interactively from the terminal to configure the exporter. 
 
For interactive installation using curl, please invoke...
 
```
bash -c "$(curl -Ls https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/redis_exporter/install.sh)" --interactive
``` 

For interactive installation using wget, please invoke...

```
bash -c "$(wget -qO- https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/redis_exporter/install.sh)" --interactive
```
