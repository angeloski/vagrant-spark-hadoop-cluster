#!/bin/bash
source "/vagrant/scripts/common.sh"

function disableFirewall {
	echo "disabling firewall"
	service iptables save
	service iptables stop
	chkconfig iptables off
}

function installDependencies {
	yum install epel-release -y
	yum install -y python-pip -y
	yum install python-devel -y
}

echo "setup centos"

disableFirewall
installDependencies