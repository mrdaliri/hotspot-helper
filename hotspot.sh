#!/bin/sh
## Hotspot Helper
## Bash script for logging in and logging out into captive portals (hotspots)
## Currently only MikroTik RouterOS (UserManager package) is supported
##
## Version 1.0
## 
## Usage: To log in:  ./hotspot.sh USERNAME (it will ask for password, your password is hidden)
##        To log out: ./hotspot.sh --logout
##
## Created by Mohamamd-Reza Daliri
## https://github.com/mrdaliri/hotspot-helper
##
## Released under MIT License, copyright (c) 2018 Mohammad-Reza Daliri
##

HOTSPOT="https://hotspot.um.ac.ir"

doLogin() {
    response=$(curl -sS "${HOTSPOT}/login" -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H "Origin: ${HOTSPOT}" -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9' -H 'User-Agent: Mozilla/5.0 (compatible; MSIE 10.0; Macintosh; Intel Mac OS X 10_7_3; Trident/6.0)' -H "Referer: ${HOTSPOT}/login" -H 'Accept-Language: en-US,en;q=0.9' --data "dst=&popup=true&username=${username}+&password=${password}");

    if [ $? != 0 ]; then
        echo "Connection to hotspot failed."
        exit 1
    elif [[ "${response}" == *"/status"* ]]; then
        echo "Connected successfully!"
    else
        error=$(echo "${response}" | grep -E -o 'var\s+\$_error\s+=\s+"(.*?)"' | grep -E -o '"(.*?)"' | cut -d '"' -f2);
        echo "Error: ${error}"
        exit 1
    fi
}

doLogout() {
    response=$(curl -sS "${HOTSPOT}/logout");
    if [ $? != 0 ]; then
        echo "Connection to hotspot failed."
        exit 1
    elif [[ "${response}" == *"/login"* ]]; then
        echo "Logged out successfully!"
    else
        echo "Unknown error"
        exit 1
    fi
}

action=$1
if [ -z "$action" ]; then
    echo 'No argument supplied!'
    exit 1
elif [ "$action" = "--logout" ]; then
    doLogout
else
    username=$1
    echo "Hostpot Username:" $username
    read -sp "Hotspot Password: " password

    printf '\n\n'
    doLogin username password
fi