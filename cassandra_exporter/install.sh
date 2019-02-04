#!/bin/bash

if [ -r ../common.sh ]; then
	. ../common/common.sh
else
	curl=$(which curl)
	r=$?
	if [ $r == 0 ]; then
		$curl -o /tmp/common.sh https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/common/common.sh
	else
		wget=$(which wget)
		r=$?
		if [ $r == 0 ]; then
			$wget -O /tmp/common.sh https://raw.githubusercontent.com/phakudi/prometheus-exporters/master/common/common.sh
		else
			echo "Neither 'curl' nor 'wget' found. Please install at least one of these packages."
			exit 1
		fi
	fi
	. /tmp/common.sh
fi

PACKAGE_NAME='cassandra-exporter'
OS=$(get_os)

DEFAULT_CASSANDRA_HOST='localhost'
DEFAULT_CASSANDRA_PORT='7199'
DEFAULT_CASSANDRA_JMX_URL='service:jmx:rmi:///jndi/rmi://localhost:7199/jmxrmi'
DEFAULT_CASSANDRA_ALIAS=$(hostname -s)
DEFAULT_CASSANDRA_PASSWORD=""

function configure_exporter() {
	if [ -z "$1" ] || [ ! "$1" == "--interactive" ]
	then
		configure_exporter_noninteractively
	else
		configure_exporter_interactively
	fi
}

function configure_exporter_noninteractively() {
	print_message "info" "Command line option --interactive not found. Proceeding in non-interactive mode.\n"
	if [ -z "$CASSANDRA_JMX_URL" ];
	then
		CASSANDRA_JMX_URL=${DEFAULT_CASSANDRA_JMX_URL}
		print_message "warn" "Env variable CASSANDRA_JMX_URL not found. Using Default (${CASSANDRA_JMX_URL}) for accessing Cassandra JMX Metrics. Please edit /etc/default/cassandra-exporter if you would like to change it later.\n"
	fi
	if [ -z "$CASSANDRA_ALIAS" ];
	then
		CASSANDRA_ALIAS=${DEFAULT_CASSANDRA_ALIAS}
		print_message "warn" "Env variable CASSANDRA_ALIAS not found. Using Default (${CASSANDRA_ALIAS}) for Cassandra Metrics. Please edit /etc/default/cassandra-exporter if you would like to change it later.\n"
	fi
	print_message "info" "Using CASSANDRA_JMX_URL=$CASSANDRA_JMX_URL CASSANDRA_ALIAS=$CASSANDRA_ALIAS to configure exporter.\n"
	update_exporter_configuration $CASSANDRA_JMX_URL $CASSANDRA_ALIAS
}

function configure_exporter_interactively() {
	print_message "info" "Interactive Configuration for Cassandra Exporter\n"
	read -p "Cassandra IP/Host [$DEFAULT_CASSANDRA_HOST] : " cassandra_host
	cassandra_host=${cassandra_host:-${DEFAULT_CASSANDRA_HOST}}
	read -p "Cassandra JMX Port [$DEFAULT_CASSANDRA_PORT] : " cassandra_port
	cassandra_port=${cassandra_port:-${DEFAULT_CASSANDRA_PORT}}
	read -p "Cassandra alias for metrics [$cassandra_host] : " cassandra_alias
	cassandra_alias=${cassandra_alias:-${cassandra_host}}
	cassandra_jmx_url="service:jmx:rmi:///jndi/rmi://$cassandra_host:$cassandra_port/jmxrmi"
	update_exporter_configuration $cassandra_jmx_url $cassandra_alias
}

function update_exporter_configuration() {
	print_message "info" "Updating exporter configuration..."
	sed \
		-e "s|jmxUrl: ${DEFAULT_CASSANDRA_JMX_URL}|jmxUrl: ${1}|g" \
		-e "s|      \"alias\": \"localhost\"|      \"alias\": \"${2}\"|g" \
		-i /opt/prometheus/cassandra_exporter/conf/cassandra.yml
	print_message "info" "DONE\n"
}

trap 'post_error ${PACKAGE_NAME}' ERR
check_root
setup_log $PACKAGE_NAME
post_complete $PACKAGE_NAME

case $OS in
    RedHat)
        install_redhat $PACKAGE_NAME
        configure_exporter $0
        start_service $PACKAGE_NAME
        ;;

    Debian)
        install_debian $PACKAGE_NAME
        configure_exporter $0
        start_service $PACKAGE_NAME
        ;;

    *)
        print_message "error" "Your OS/distribution is not supported by this install script.\n"
        exit 1;
        ;;
esac
