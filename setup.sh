#!/bin/bash
# Author: Yevgeniy Goncharov aka xck, http://sys-adm.in
# Enable / Disable Firewalld DROP, REJECT logs

# Sys env / paths / etc
# ---------------------------------------------------------------------\
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)


# Get args, Usage help
# ---------------------------------------------------------------------\

# Help information
usage() {

    echo -e "\nArguments:
    -e (enable logging)
    -d (disable logging)\n"
    exit 1

}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -e|--enable) _ENABLE=1; ;;
        -d|--disable) _DISABLE=1; ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Additional Vars
# ---------------------------------------------------------------------\
_fwd_stat=$(firewall-cmd --get-log-denied)

# Functions
# ---------------------------------------------------------------------\
# Check is current user is root
isRoot() {
    if [ $(id -u) -ne 0 ]; then
        echo "You must be root user to continue"
        exit 1
    fi
    RID=$(id -u root 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "User root no found. You should create it to continue"
        exit 1
    fi
    if [ $RID -ne 0 ]; then
        echo "User root UID not equals 0. User root must have UID 0"
        exit 1
    fi
}

disableLogrotate() {
    rm /etc/rsyslog.d/firewalld.conf
    systemctl restart rsyslog.service
}

defineLogrotate() {
    echo -e "
# DROP, REJECT in to /var/log/firewalld.log
:msg,contains,"_DROP" /var/log/firewalld.log
& stop
:msg,contains,"_REJECT" /var/log/firewalld.log
& stop
    " > /etc/rsyslog.d/firewalld.conf

    systemctl restart rsyslog.service
}


disableLogging() {

    if [[ "${_fwd_stat}" =~ "all" ]]; then
        echo "Firewall log-denied current status: all, disabling..."
        firewall-cmd --set-log-denied=off
        disableLogrotate
    else
        echo "Firewall log-denied already configured."
        echo "Current setting is: ${_fwd_stat}."
        echo "Exit. Bye."
        exit 0
    fi
}

enableLogging() {

    if [[ "${_fwd_stat}" =~ "off" ]]; then
        echo "Firewall log-denied current status: off, enabling..."
        firewall-cmd --set-log-denied=all
        defineLogrotate
    else
        echo "Firewall log-denied already enabled or configured."
        echo "Current setting is: ${_fwd_stat}."
        echo "Exit. Bye."
        exit 0
    fi
}

# Actions
# ---------------------------------------------------------------------\
isRoot

if [[ $# -eq 0 ]]; then
    echo "Use parameters please. Exit. Bye."
    usage
    exit 0
elif [[ "$_ENABLE" -eq "1" ]]; then
    echo "Enable logging..."
    enableLogging
elif [[ "$_DISABLE" -eq "1" ]]; then
    echo "Disable logging..."
    disableLogging
else 
    echo "Unknown command. Exit. Bye."
    exit 1
fi




