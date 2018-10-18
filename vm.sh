#!/bin/bash

Print() {

	case $3 in 
		B) COL="\e[34m" ;;
		G) COL="\e[32m" ;;
		Y) COL="\e[33m" ;;
		R) COL="\e[31m" ;;
	esac

			if [ "$1" = SL ]; then 
				echo -n -e "$COL$2\e[0m"
			elif [ "$1" = NL ]; then 
				echo -e "$COL$2\e[0m"
			else
				echo -e "$COL$2\e[0m"
			fi
}

SELINUX() {
    Print "SL" "=>> Checking SELINUX.. " "B"
	S=$(sestatus  |grep 'SELinux status'  |awk '{print $NF}')
	if [ "$S" = "enabled" ]; then 
		Print "NL" "Enabled.." "R"
		Print "SL" "+>> Disabling SELINUX.." B
		sed -i -e '/^SELINUX/ c SELINUX=disabled' /etc/selinux/config
		Print "NL" "Success" G
		rreq=yes
	else
		Print NL "Disabled" G
	fi 
}

PACK() {

	Print SL "=>> Installing base Packages.. " B
	yum install wget zip unzip gzip vim net-tools facter bzip2 -y &>/dev/null
	Print NL Success G
}

if [ $(rpm -qa |grep ^base |awk -F . '{print $(NF-1)}') = "el6" ]; then 
	SELINUX
	Print "SL" "=>> Disabling Firewall.. " "B"
    service iptables stop &>/dev/null && service ip6tables stop &>/dev/null && chkconfig iptables off && chkconfig ip6tables off
    if [ $? -eq 0 ]; then 
		Print NL Success G
	else
		Print NL Failure R
	fi

	LENV
	PACK

	if [ "$rreq" = "yes" ]; then 
		Print "NL" "Rebooting Server.. Try to connect back in 15 sec" R
		reboot
	fi

	Print NL "Run of Init Script .. Completed.. System is ready to use" B 
	exit 0
fi 


SELINUX
Print "SL" "=>> Disabling Firewall.. " "B"
systemctl disable firewalld &>/dev/null
if [ $? -eq 0 ]; then 
	Print NL Success G
else
	Print NL Failure R
fi

PACK
LENV

if [ "$rreq" = "yes" ]; then 
	Print "NL" "Rebooting Server.. Try to connect back in 15 sec" R
	reboot
fi

Print NL "Run of Init Script .. Completed.. System is ready to use" B 
