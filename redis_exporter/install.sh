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

PACKAGE_NAME='redis-exporter'
OS=$(get_os)

DEFAULT_REDIS_HOST='localhost'
DEFAULT_REDIS_PORT='6379'
DEFAULT_REDIS_ADDR='redis://localhost:6379'
DEFAULT_REDIS_ALIAS=$(hostname -s)
DEFAULT_REDIS_PASSWORD=""

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
	if [ -z "$REDIS_ADDR" ];
	then
		REDIS_ADDR=${DEFAULT_REDIS_ADDR}
		print_message "warn" "Env variable REDIS_ADDR not found. Using Default Redis Address (${REDIS_ADDR}) for accessing Redis Metrics. Please edit /etc/default/redis-exporter if you would like to change it later.\n"
	fi
	if [ -z "$REDIS_ALIAS" ];
	then
		REDIS_ALIAS=${DEFAULT_REDIS_ALIAS}
		print_message "warn" "Env variable REDIS_ALIAS not found. Using Default Redis Alias (${REDIS_ALIAS}) for Redis Metrics. Please edit /etc/default/redis-exporter if you would like to change it later.\n"
	fi
	if [ -z "$REDIS_PASSWORD" ];
	then
		REDIS_PASSWORD=${DEFAULT_REDIS_PASSWORD}
		print_message "warn" "Env variable REDIS_PASSWORD not found. Using Default Redis Password for accessing Redis Metrics. Please edit /etc/default/redis-exporter if you would like to change it later.\n"
	fi
	print_message "info" "Using REDIS_ADDR=$REDIS_ADDR REDIS_ALIAS=$REDIS_ALIAS REDIS_PASSWORD=xxxx to configure exporter.\n"
	update_exporter_configuration $REDIS_ADDR $REDIS_ALIAS $REDIS_PASSWORD
}

function configure_exporter_interactively() {
	print_message "info" "Interactive Configuration for Redis Exporter\n"
	read -p "Redis IP/Host [$DEFAULT_REDIS_HOST] : " redis_host
	redis_host=${redis_host:-${DEFAULT_REDIS_HOST}}
	read -p "Redis Port [$DEFAULT_REDIS_PORT] : " redis_port
	redis_port=${redis_port:-${DEFAULT_REDIS_PORT}}
	read -p "Redis alias for metrics [$redis_host] : " redis_alias
	redis_alias=${redis_alias:-${redis_host}}
	read -p "Redis Password (if any, else press ENTER) : " -s redis_password
	redis_password=${redis_password:-${DEFAULT_REDIS_PASSWORD}}
	redis_addr="redis://$redis_host:$redis_port"
	update_exporter_configuration $redis_addr $redis_alias $redis_password
}

function update_exporter_configuration() {
	print_message "info" "Updating exporter configuration..."
	sed \
		-e "s|export REDIS_ADDR=\"${DEFAULT_REDIS_ADDR}\"|export REDIS_ADDR=\"${1}\"|g" \
		-e "s|export REDIS_ALIAS=\"localhost\"|export REDIS_ALIAS=\"${2}\"|g" \
		-e "s|export REDIS_PASSWORD=\"\"|export REDIS_PASSWORD=\"${3}\"|g" \
		-i /etc/default/redis-exporter
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
