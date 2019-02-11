# Memcache Metrics Exporter [![Build Status](https://travis-ci.com/ApptuitAI/prometheus-exporters.svg?branch=master)](https://travis-ci.com/ApptuitAI/prometheus-exporters)

Prometheus exporter for Memcache metrics for reporting metrics to Apptuit.ai

### Installation

Memcache Exporter is available via debian & yum repositories.

#### Non-Interactive installation

This is the default mode of installation. In this mode, the installer script assumes that you have a memcache instance
up and running and reads the following environment variable(s) for the exporter congiguration needed. Please be sure to 
set them up with the appropriate value(s) before invoking the commands below.

For default install using curl, please use...

```bash
MEMCACHE_ADDRESS="<memcache_host>:<memcache_port>" bash -c "$(curl -Ls https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/memcached_exporter/install.sh)"
```

For non-interactive install using wget please use...

```bash
MEMCACHE_ADDRESS="<memcache_host>:<memcache_port>" bash -c "$(wget -qO- https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/memcached_exporter/install.sh)"
```
In absence of the MEMCACHE_ADDRESS environment variable, the installer script assumes a default address - 
"localhost:11211". You can change this anytime after installation by editing 
the value of the parameter '--memcached.address' included in EXPORTER_FLAGS variable in 
/etc/default/memcached-exporter.

##### Interactive installation

This mode of installation takes inputs interactively from the terminal to configure the exporter. 
 
For interactive installation using curl, please invoke...
 
```
bash -c "$(curl -Ls https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/memcached_exporter/install.sh)" --interactive
``` 

For interactive installation using wget, please invoke...

```
bash -c "$(wget -qO- https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/memcached_exporter/install.sh)" --interactive
```

The interactive install takes you through input prompts for IP and Port where Memcache is running in order to arrive at 
the MEMCACHE_ADDRESS.
