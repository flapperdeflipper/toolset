#!/usr/bin/env bash
# shellcheck disable=SC2312

################################################################################
## Exit functions for scripts                                                 ##
################################################################################

##
## Print to log and exit with exit_code
##

function exit::log {
    local message="${1}"
    local severity="${2}"
    local exit_code="${3:-0}"

    log::trace "${FUNCNAME[0]}: ${*} - Logging to output with ${severity} and exit ${exit_code}"

    log::logger "${message}" "${severity}"

    exit "${exit_code}"
}


##
## Print to log and exit OK
##

function exit::info {
    local message="${1}"
    local exit_code="${2:-0}"

    log::trace "${FUNCNAME[0]}: ${*} - Logging OK and exiting"

    exit::log "${message}" INFO "${exit_code}"
}


function exit::ok { exit::info "${@}"; }


##
## Print debug to log and exit OK
##

function exit::debug {
    local message="${1}"
    local exit_code="${2:-0}"

    log::trace "${FUNCNAME[0]}: ${*} - Logging DEBUG and exiting"

    exit::log "${message}" DEBUG "${exit_code}"
}


##
## Print trace to log and exit OK
##

function exit::trace {
    local message="${1}"
    local exit_code="${2:-0}"

    log::trace "${FUNCNAME[0]}: ${*} - Logging TRACE and exiting"

    exit::log "${message}" TRACE "${exit_code}"
}


##
## Print warning to log and exit NOK
##

function exit::warning {
    local message="${1}"
    local exit_code="${2:-1}"

    log::trace "${FUNCNAME[0]}: ${*} - Logging WARNING and exiting"

    exit::log "${message}" WARNING "${exit_code}"
}

function exit::warn { exit::warning "${@}"; }


##
## Print error to log and exit NOK
##

function exit::error {
    local message="${1}"
    local exit_code="${2:-1}"

    log::trace "${FUNCNAME[0]}: ${*} - Logging ERROR and exiting"

    exit::log "${message}" ERROR "${exit_code}"
}


function exit::err { exit::error "${@}"; }
function exit::fatal { exit::error "${@}"; }
function exit::die { exit::error "${@}"; }


##
## Print output in white from stdin with level INPUT and exit
##

function exit::stdin {
    local -r level="${1:-INFO}"
    local -i exit_code="${2:-0}"

    log::trace "${FUNCNAME[*]}: ${*}"

    cat - | log::stdin "${level}"

    exit "${exit_code}"
}


##
## Error out when input is false
##

function exit::if_false {
    local value="${1:-}"
    local message="${2:-}"
    local severity="${3:-"ERROR"}"
    local exit_code="${4:-1}"

    log::trace "${FUNCNAME[0]}: ${*} - Error out when input is false"

    if var::is_false "${value}"
    then
        exit::log "${message}" "${severity}" "${exit_code}"
    fi
}


##
## Error out if input is true
##

function exit::if_true {
    local value="${1:-}"
    local message="${2:-}"
    local severity="${3:-"ERROR"}"
    local exit_code="${4:-1}"

    log::trace "${FUNCNAME[0]}: ${*} - Error out when input is true"

    if var::is_true "${value}"
    then
        exit::log "${message}" "${severity}" "${exit_code}"
    fi
}


##
## Error out if input is empty
##

function exit::if_empty {
    local value="${1:-}"
    local message="${2:-}"
    local severity="${3:-"ERROR"}"
    local exit_code="${4:-1}"

    log::trace "${FUNCNAME[0]}: ${*} - Error out when input is empty"

    if var::is_empty "${value}"
    then
        exit::log "${message}" "${severity}" "${exit_code}"
    fi
}


##
## Error out if input is equal to
##

function exit::if_equals {
    local value1="${1:-}"
    local value2="$2:-}"
    local message=${3:-}
    local severity="${4:-"ERROR"}"
    local exit_code="${5:-1}"

    log::trace "${FUNCNAME[0]}: ${*} - Error out when input ${value1} equals ${value2}"

    if var::equals "${value1}" "${value2}"
    then
        exit::log "${message}" "${severity}" "${exit_code}"
    fi
}
