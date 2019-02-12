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

PACKAGE_NAME='memcached-exporter'
OS=$(get_os)

DEFAULT_MEMCACHE_HOST='localhost'
DEFAULT_MEMCACHE_PORT='11211'
DEFAULT_MEMCACHE_ADDRESS='localhost:11211'

function configure_exporter_interactively() {
	read -p "Memcache IP [$DEFAULT_MEMCACHE_HOST] : " memcache_host
	memcache_host=${memcache_host:-${DEFAULT_MEMCACHE_HOST}}
	read -p "Memcache Port [$DEFAULT_MEMCACHE_PORT] : " memcache_port
	memcache_port=${memcache_port:-${DEFAULT_MEMCACHE_PORT}}
	memcache_address="$memcache_host:$memcache_port"
	update_exporter_configuration $memcache_address
}

function configure_exporter_noninteractively() {
	print_message "info" "Command line option --interactive not found. Proceeding in non-interactive mode.\n"
	if [ -z "$MEMCACHE_ADDRESS" ];
	then
		MEMCACHE_ADDRESS=${DEFAULT_MEMCACHE_ADDRESS}
		print_message "warn" "Env variable MEMCACHE_ADDRESS not found. Using Default address ($MEMCACHE_ADDRESS) for accessing memcache instance. Please edit /etc/default/memcached-exporter if you would like to change it later.\n"
	else
		print_message "info" "Using MEMCACHE_ADDRESS=$MEMCACHE_ADDRESS to configure exporter.\n"
		update_exporter_configuration $MEMCACHE_ADDRESS
	fi
}

function update_exporter_configuration() {
	print_message "info" "Updating exporter configuration..."
	sed -e "s|export EXPORTER_FLAGS=\"--memcached.address=localhost:11211\"|export EXPORTER_FLAGS=\"--memcached.address=${1}\"|g" -i /etc/default/memcached-exporter
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
