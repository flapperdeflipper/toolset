#!/usr/bin/env bash

function system::detect_mac_version {
    depends::check "sw_vers" || return 1

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving mac software version"

    sw_vers -productVersion

    return "${?}"
}

function system::is_mac {
    if [[ "$( uname )" == "Darwin" ]]
    then
        return 0
    fi

    return 1
}

