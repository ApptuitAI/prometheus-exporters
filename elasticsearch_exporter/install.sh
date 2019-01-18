#!/bin/bash

if [ -r ../common.sh ]; then
	. ../common/common.sh
else
	curl=$(which curl)
	r=$?
	if [ $r == 0 ]; then
		$curl -o /tmp/common.sh https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/common/common.sh
	else
		wget=$(which wget)
		r=$?
		if [ $r == 0 ]; then
			$wget -O /tmp/common.sh https://raw.githubusercontent.com/ApptuitAI/prometheus-exporters/master/common/common.sh
		else
			echo "Neither 'curl' nor 'wget' found. Please install at least one of these packages."
			exit 1
		fi
	fi
	. /tmp/common.sh
fi

PACKAGE_NAME='elasticsearch-exporter'
OS=$(get_os)

DEFAULT_ELASTICSEARCH_URL='http://localhost:9200'

function configure_exporter_interactively() {
	read -p "Elasticsearch URL [ $DEFAULT_ELASTICSEARCH_URL ] : " es_url
	es_url=${es_url:-${DEFAULT_ELASTICSEARCH_URL}}
	update_exporter_configuration $es_url
}

function configure_exporter_noninteractively() {
	print_message "info" "Command line option --interactive not found. Proceeding in non-interactive mode.\n"
	if [ -z "$ES_URL" ];
	then
		ES_URL=${DEFAULT_ELASTICSEARCH_URL}
		print_message "warn" "Env variable ES_URL not found. Using Default Datasource URL (${ES_URL}) for accessing Elasticsearch cluster. Please edit /etc/default/elasticsearch-exporter if you would like to change it later.\n"
	else
		print_message "info" "Using ES_URL=$ES_URL to configure datasource for exporter.\n"
		update_exporter_configuration $ES_URL
	fi
}

function update_exporter_configuration() {
	print_message "info" "Updating exporter configuration..."
	sed -e "s|export EXPORTER_FLAGS=\"-es.uri=http://localhost:9200\"|export EXPORTER_FLAGS=\"-es.uri=${1}\"|g" -i /etc/default/elasticsearch-exporter
	print_message "info" "DONE\n"
}

function configure_exporter() {
	if [ -z "$1" ] || [ ! "$1" == "--interactive" ]
	then
		configure_exporter_noninteractively
	else
		configure_exporter_interactively
	fi
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
