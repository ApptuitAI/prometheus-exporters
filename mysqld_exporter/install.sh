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

PACKAGE_NAME='mysqld-exporter'
OS=$(get_os)

DEFAULT_MYSQL_HOST='localhost'
DEFAULT_MYSQL_PORT='3306'
DEFAULT_MYSQL_USER='prometheus'
DEFAULT_MYSQL_PASSWORD='prometheus'
DEFAULT_MYSQL_URL='prometheus:prometheus@(localhost:3306)/'

function check_valid_mysql_user() {
	local host=$1
	local port=$2
	local user=$3
	local password=$4
	numrows=$(mysql -u ${user} -p${password} -h ${host} -P ${port} -e "select count(*)" 2>/dev/null)
	if [ ! -z "$numrows" ]; then
		n=$(echo $numrows | cut -d " " -f2)
		if [ $n -eq 1 ]; then
			return 1
		fi
	fi
	print_message "warn" "Invalid mysql user '$user'. Would you like to create the user? Requires you to provide the mysql root password. (y/n)?"
	read yesno
	case $yesno in
		[Yy]* ) create_mysql_user $host $port $user $password; return 1;;
		[Nn]* ) print_mysql_user_creation_help $host $port $user $password;;
	esac
	return -1
}

function create_mysql_user() {
	local host=$1
	local port=$2
	local mysql_user=$3
	local mysql_user_password=$4
	read -p "Password for MySQL 'root' User : " -s mysql_root_password
	print_message "info" "Creating MySQL user '${mysql_user}' and granting needed permissions..."
	mysql -u root -p${mysql_root_password} -h ${host} -P ${port} -e "CREATE USER '${mysql_user}'@'localhost' IDENTIFIED BY '${mysql_user_password}';"
	mysql -u root -p${mysql_root_password} -h ${host} -P ${port} -e "GRANT PROCESS ON *.* TO '${mysql_user}'@'localhost';"
	mysql -u root -p${mysql_root_password} -h ${host} -P ${port} -e "GRANT SELECT ON performance_schema.* TO '${mysql_user}'@'localhost';"
	mysql -u root -p${mysql_root_password} -h ${host} -P ${port} -e "GRANT REPLICATION CLIENT ON *.* to '${mysql_user}'@'localhost';"
	print_message "success" "Done"
}

function print_mysql_user_creation_help() {
	print_message "info" "\n\nPlease run the following commands manually as mysql 'root' user to create user - '$3'\n\n"
	print_message "info" "mysql -u root -p -h $1 -P $2 -e \"CREATE USER '${3}'@'localhost' IDENTIFIED BY '$4';\"\n"
	print_message "info" "mysql -u root -p -h $1 -P $2 -e \"GRANT PROCESS ON *.* TO '${3}'@'localhost';\"\n"
	print_message "info" "mysql -u root -p -h $1 -P $2 -e \"GRANT SELECT ON performance_schema.* TO '${3}'@'localhost';\"\n"
	print_message "info" "mysql -u root -p -h $1 -P $2 -e \"GRANT REPLICATION CLIENT ON *.* to '${3}'@'localhost';\"\n\n"
}

function configure_exporter_interactively() {
	print_message "info" "Interactive Configuration for MySQL Exporter\n"
	read -p "MySQL IP [$DEFAULT_MYSQL_HOST] : " mysql_host
	mysql_host=${mysql_host:-${DEFAULT_MYSQL_HOST}}
	read -p "MySQL Port [$DEFAULT_MYSQL_PORT] : " mysql_port
	mysql_port=${mysql_port:-${DEFAULT_MYSQL_PORT}}
	read -p "MySQL User for metrics collection [$DEFAULT_MYSQL_USER] : " mysql_user
	mysql_user=${mysql_user:-${DEFAULT_MYSQL_USER}}
	read -p "Password for '${mysql_user}' User : " -s mysql_user_password
	check_valid_mysql_user $mysql_host $mysql_port $mysql_user $mysql_user_password
	isvalid=$?
	if [ -z $isvalid ] || [ "$isvalid" != "1" ]; then
		read -p "Have you manually created the user? Would you like to proceed? (y/n)?" yesno
		yesno=${yesno:-y}
		case $yesno in
			[Nn]* ) exit;;
		esac
	fi
	mysql_url="$mysql_user:$mysql_user_password@($mysql_host:$mysql_port)/"
	update_exporter_configuration $mysql_url
}

function configure_exporter_noninteractively() {
	print_message "info" "Command line option --interactive not found. Proceeding in non-interactive mode.\n"
	if [ -z "$MYSQL_URL" ];
	then
		MYSQL_URL=${DEFAULT_MYSQL_URL}
		print_message "warn" "Env variable MYSQL_URL not found. Using Default Datasource URL (${MYSQL_URL}) for accessing MySQL instance. Please edit /etc/default/mysqld-exporter if you would like to change it later.\n"
	else
		print_message "info" "Using MYSQL_URL=$MYSQL_URL to configure datasource for exporter.\n"
		update_exporter_configuration $MYSQL_URL
	fi
}

function update_exporter_configuration() {
	print_message "info" "Updating exporter configuration..."
	sed -e "s|export DATA_SOURCE_NAME=\"prometheus:prometheus@(localhost:3306)/\"|export DATA_SOURCE_NAME=\"${1}\"|g" -i /etc/default/mysqld-exporter
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
