#!/bin/bash

BINTRAY_REPO_COMPANY=apptuitai
DEBIAN_REPO_NAME=debian
RPM_REPO_NAME=rpm

function check_root() {
	if [ "$EUID" -ne 0 ]
	  then echo "Please run as root"
	  exit
	fi
}

function setup_log () {
    logfile="$1-install.log"

    # location of named pipe is /tmp/pid.tmp
    named_pipe=/tmp/$$.tmp
    # delete the named pipe on exit
    trap "rm -f $named_pipe" EXIT
    # create the named pipe
    mknod $named_pipe p

    # Tee named pipe to both log and STDOUT
    tee <$named_pipe $logfile &
    # Direct all script output to named pipe
    exec 1>$named_pipe 2>&1

}

function get_os () {
    # Try lsb_release, fallback with /etc/issue then uname command
    KNOWN_DISTRIBUTION="(Debian|Ubuntu|RedHat|CentOS|openSUSE|Amazon|Arista|SUSE)"
    DISTRIBUTION=$(lsb_release -d 2>/dev/null | grep -Eo $KNOWN_DISTRIBUTION  || grep -Eo $KNOWN_DISTRIBUTION /etc/issue 2>/dev/null || grep -Eo $KNOWN_DISTRIBUTION /etc/Eos-release 2>/dev/null || uname -s)

    if [ $DISTRIBUTION = "Darwin" ]; then
        OS="Mac"
    elif [ -f /etc/debian_version -o "$DISTRIBUTION" == "Debian" -o "$DISTRIBUTION" == "Ubuntu" ]; then
        OS="Debian"
    elif [ -f /etc/redhat-release -o "$DISTRIBUTION" == "RedHat" -o "$DISTRIBUTION" == "CentOS" -o "$DISTRIBUTION" == "Amazon" ]; then
        OS="RedHat"
    # Some newer distros like Amazon may not have a redhat-release file
    elif [ -f /etc/system-release -o "$DISTRIBUTION" == "Amazon" ]; then
        OS="RedHat"
    # Arista is based off of Fedora14/18 but do not have /etc/redhat-release
    elif [ -f /etc/Eos-release -o "$DISTRIBUTION" == "Arista" ]; then
        OS="RedHat"
    # openSUSE and SUSE use /etc/SuSE-release
    elif [ -f /etc/SuSE-release -o "$DISTRIBUTION" == "SUSE" -o "$DISTRIBUTION" == "openSUSE" ]; then
        OS="SUSE"
    fi
    echo $OS
}

function print_message () {
    local log_level="info"
    local log_message=$1
    if [ $# == 2 ] ; then
        log_level=$1;
        log_message=$2;
    fi

    if [ "$log_level" == "info" ] ; then
        COLOR="34m";
    elif [ "$log_level" == "success" ] ; then
        COLOR="32m";
    elif [ "$log_level" == "warn" ] ; then
        COLOR="33m";
    elif [ "$log_level" == "error" ] ; then
        COLOR="31m";
    else #default color
        COLOR="0m";
    fi

    STARTCOLOR="\e[$COLOR";
    ENDCOLOR="\e[0m";

    printf "$STARTCOLOR%b$ENDCOLOR" "$log_message";

}

function update_config () {
    print_message "Updating access token in: /etc/xcollector/xcollector.yml\n"
    $sudo_cmd sh -c "sed -e 's/access_token:.*/access_token: $xc_access_token/' -i /etc/xcollector/xcollector.yml"

    if [ -n "$xc_global_tags" ]; then
        print_message "Updating tags in: /etc/xcollector/xcollector.yml\n"
        $sudo_cmd sh -c "/usr/local/xcollector/xcollector.py --set-option-tags $xc_global_tags"
    fi

}

function post_complete () {
    print_message "success" "Installation of $1 completed successfully\n"
}

function post_error () {
    print_message "error" "Installation of $1 failed\n"
}

function start_service () {
    restart_cmd="$sudo_cmd /etc/init.d/$1 restart"
    if [ $(command -v service) ]; then
        restart_cmd="$sudo_cmd service $1 restart"
    elif [ $(command -v invoke-rc.d) ]; then
        restart_cmd="$sudo_cmd invoke-rc.d $1 restart"
    fi

    print_message "Starting $1\n"
    eval $restart_cmd
}

function install_debian () {
    print_message "Installing apt-transport-https\n"
    $sudo_cmd apt-get update || printf "'apt-get update' failed, dependencies might not be updated to latest version.\n"
    $sudo_cmd apt-get install -y apt-transport-https
    # Only install dirmngr if it's available in the cache
    # it may not be available on Ubuntu <= 14.04 but it's not required there
    cache_output=$(apt-cache search dirmngr)
    if [ ! -z "$cache_output" ]; then
        print_message "Installing dirmngr\n"
        $sudo_cmd apt-get install -y dirmngr
    fi

    print_message "Installing APT source list for $1\n"
    $sudo_cmd sh -c "echo 'deb https://dl.bintray.com/${BINTRAY_REPO_COMPANY}/${DEBIAN_REPO_NAME}/ stable main' > /etc/apt/sources.list.d/apptuit.list"
    print_message "Installing GPG keys for $1\n"
    $sudo_cmd apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61

    print_message "Updating $1 repo\n"
    $sudo_cmd apt-get update -o Dir::Etc::sourcelist="sources.list.d/apptuit.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
    print_message "Installing $1\n"
    $sudo_cmd apt-get install -y --allow-unauthenticated $1
}

function install_redhat () {
    print_message "Installing YUM sources for Apptuit\n"
    $sudo_cmd sh -c "echo -e '[apptuit]\nname=Apptuit.AI\nbaseurl=https://dl.bintray.com/${BINTRAY_REPO_COMPANY}/${RPM_REPO_NAME}\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=0\n' > /etc/yum.repos.d/apptuit.repo"

    print_message "Installing $1\n"
    $sudo_cmd yum -y install $1
}
