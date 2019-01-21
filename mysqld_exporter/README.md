# MySQL Server Metrics Exporter [![Build Status](https://travis-ci.com/ApptuitAI/prometheus-exporters.svg?branch=master)](https://www.travis-ci.org/ApptuitAI/prometheus-exporters)

Prometheus exporter for MySQL Server metrics for reporting metrics to Apptuit.ai

### Installation

MySQL Exporter is available via debian & yum repositories.

If you would like to manually setup a user on the MySQL database for the exporter, please use the SQL commands below 
as 'root' user.
 
```
sudo mysql -e "CREATE USER 'xcollector'@'localhost' IDENTIFIED BY 'changeme';"
sudo mysql -e "GRANT PROCESS ON *.* TO 'xcollector'@'localhost';"
sudo mysql -e "GRANT SELECT ON performance_schema.* TO 'xcollector'@'localhost';"
sudo mysql -e "GRANT REPLICATION CLIENT ON *.* to 'xcollector'@'localhost';"
```

#### Non-Interactive installation

This is the default mode of installation. In this mode, the installer script assumes that you have a MySQL database 
up and running and have already setup a database user for the exporter (using the SQL commands above).
The installer reads the following environment variable(s) for the inputs it needs. Please be sure to set them up with 
the appropriate value(s) before invoking the commands below.

For default non-interactive install using curl, please use...

```bash
MYSQL_URL="<mysql_user_name>:<mysql_user_password>@(<mysql_host>:<mysql_port>)/" bash -c "$(curl -Ls https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/mysqld_exporter/install.sh)"
```

For non-interactive install using wget please use...

```bash
MYSQL_URL="<mysql_user_name>:<mysql_user_password>@(<mysql_host>:<mysql_port>)/" bash -c "$(wget -qO- https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/mysqld_exporter/install.sh)"
```

In absence of the MYSQL_URL environment variable, the installer script assumes a default data source - 
"prometheus:prometheus@(localhost:3306)/". You can change this anytime after installation by editing 
the value of the environment variable DATA_SOURCE_NAME in /etc/default/mysqld-exporter.

##### Interactive installation

This mode of installation takes inputs interactively from the terminal to configure the exporter. 
 
For interactive installation using curl, please invoke...
 
```
bash -c "$(curl -Ls https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/mysqld_exporter/install.sh)" --interactive
``` 

For interactive installation using wget, please invoke...

```
bash -c "$(wget -qO- https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/mysqld_exporter/install.sh)" --interactive
```

This interactive process takes you through prompts for setting up your MySQL user credentials in 
the exporter config. Also, if the user does not exist already it takes your MySQL root password as input 
to execute the following SQL commands for creating the said user on MySQL. Alternatively, based on 
your inputs it can generate the SQL commands for you to run manually as 'root' user.
