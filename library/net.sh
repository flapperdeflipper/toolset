#!/usr/bin/env bash

################################################################################
## Network and Internet related helpers                                       ##
################################################################################

##
## Get current public ip address
##

function net::get_ip {
    depends::check::silent dig || return 1

    dig +short myip.opendns.com @resolver1.opendns.com
}


##
## Check if ipv4
##

function net::is_ip4 {
    local ip="$1"
    local stat=1

    log::trace "${FUNCNAME[0]}: ${*} - Checking if ${ip} is a valid ipv4 address"

    # Check if an IP(4) address is valid
    # https://www.linuxjournal.com/content/validating-ip-address-bash-script

    if [[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
    then
        OIFS="$IFS"

        # Split IP on dots
        IFS='.'

        # shellcheck disable=SC2206
        segments=( $ip )

        IFS="$OIFS"

        # Check if all parts are in the allowed range
        [[ "${segments[0]}" -le 255 ]] \
            && [[ "${segments[1]}" -le 255 ]] \
            && [[ "${segments[2]}" -le 255 ]] \
            && [[ "${segments[3]}" -le 255 ]]

        # Set the return of the test
        stat="$?"
    fi

    return "$stat"
}


##
## Check if ipv6
##

function net::is_ip6 {
    local ip="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if ${ip} is a valid ipv6 address"

    echo "${ip}" \
       | grep -Pq '^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$'

    return $?
}


##
## Check if name is a FQDN
##

function net::is_fqdn {
    local name="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if ${name} is a valid FQDN"

    echo "${name}" \
        | grep -Pq '(?=^.{4,255}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}\.?$)'

    return $?
}


##
## Check if name is a valid email address
##

function net::is_email {
    local address="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if ${address} is a valid email"

    local regex="^(([A-Za-z0-9]+((\.|\-|\_|\+)?[A-Za-z0-9]?)*[A-Za-z0-9]+)|[A-Za-z0-9]+)@(([A-Za-z0-9]+)+((\.|\-|\_)?([A-Za-z0-9]+)+)*)+\.([A-Za-z]{2,})+$"

    [[ "${address}" =~ $regex ]]
}





################################################################################
## HTTP                                                                       ##
################################################################################

##
## debug http
##

function net::http::time {
    depends::check::silent curl || return 1

    w_string="$( \
        printf "dns:          %s\nconnect:      %s\npretransfer:  %s\nstarttransfer:%s\ntotal:        %s\n" \
        "%{time_namelookup}" \
        "%{time_connect}" \
        "%{time_pretransfer}" \
        "%{time_starttransfer}" \
        "%{time_total}\n"
    )"

    curl -qs "${@}" -o /dev/null -w "${w_string}"
}


##
## Retrieve the TTFB
##

function net::http::ttfb {
    depends::check::silent curl || return 1

    curl -kqso /dev/null "${@}" -w "%{time_starttransfer}\n"
}


##
## Site down for everyone or just me?
##

function net::http::downforme {
    depends::check::silent curl || return 1

    if [ ${#} = 0 ]
    then
        echo -e "usage: downforme website_url"
    else
        JUSTYOU="$( \
            curl "http://downforeveryoneorjustme.com/${1}" \
                | grep -o 'It.s just you' \
            )"

        if [ ${#JUSTYOU} != 0 ]
        then
            echo -e "It's just you. \n${1} is up."
        else
            echo -e "It's not just you! \n${1} looks down from here."
        fi
    fi
}

