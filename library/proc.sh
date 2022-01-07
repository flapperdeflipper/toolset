#!/usr/bin/env bash

################################################################################
## Run a command and handle output                                            ##
################################################################################

##
## Run a command and send all output to a file
##

function proc::assert_command {
    local outfile="${1}"; shift
    local command="${*}"

    if [[ ! -e "${outfile}" ]]
    then
        log::error "${FUNCNAME[0]}: Output file ${outfile} nonexistent!"
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Checking command ${command} for exitcode"

    if (set -o pipefail && bash -c "${command} 2>&1" > "${outfile}" )
    then
        return 0
    fi

    return 1
}


##
## Run a command and send all output to logger
##

function proc::log_output {
    local command="${1}"
    local severity="${2}"

    log::trace "${FUNCNAME[0]}: ${*} - Running command ${command} and sending output to log"

    (set -o pipefail && bash -c "${command} 2>&1" | log::stdin "${severity}" )

    return ${?}
}


##
## Run a command and log the output based on it's exit code
##

function proc::log_action {
    local command="${*}"
    local tmpfile

    if ! tmpfile="$( mktemp )"
    then
        log::error "${FUNCNAME[0]}: Failed to request proc::tmpfile"
        return 1
    fi

    log::info "Running command: ${command}"

    if ! proc::assert_command "${tmpfile}" "${command}"
    then
        log::error "${FUNCNAME[0]}: Failed to run ${command}"
        log::stdin "ERROR" < "${tmpfile}" && rm "${tmpfile}"
    else
        log::info "Command ${command} succeeded"
        log::stdin "DEBUG" < "${tmpfile}" && rm "${tmpfile}"
    fi

    log::info "Full output in ${tmpfile}"

    return 1
}


##
## Watch a command
##

function proc::watch {
    local command="${1}"; shift
    local args="${*}"

    log::trace "${FUNCNAME[0]}: ${*} - Watching command ${command}"

    command watch "${args}" "${command}"
}


##
## Run and or watch a command based on arguments
##

function proc::run {
    local command="${1}"; shift
    local arguments="${*}"

    log::trace "${FUNCNAME[0]}: ${*} - Running commmand ${command} with ${arguments}"

    if string::contains "watch" "${arguments}" \
        || string::contains "-w" "${arguments}"
    then
        proc::watch "${command}" -t
    else
        bash -c "${command}"
    fi
}

################################################################################
## Exit functions for scripts                                                 ##
################################################################################

##
## Print to log and exit with exit_code
##

function proc::exit_log {
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

function proc::exit_ok {
    local message="${1}"
    local exit_code="${2:-0}"

    log::trace "${FUNCNAME[0]}: ${*} - Logging OK and exiting"

    proc::exit_log "${message}" INFO "${exit_code}"
}


function proc::exit { proc::exit_ok "${@}"; }


##
## Print debug to log and exit OK
##

function proc::exit_debug {
    local message="${1}"
    local exit_code="${2:-0}"

    log::trace "${FUNCNAME[0]}: ${*} - Logging DEBUG and exiting"

    proc::exit_log "${message}" DEBUG "${exit_code}"
}


##
## Print warning to log and exit NOK
##

function proc::exit_warning {
    local message="${1}"
    local exit_code="${2:-1}"

    log::trace "${FUNCNAME[0]}: ${*} - Logging WARNING and exiting"

    proc::exit_log "${message}" WARNING "${exit_code}"
}


##
## Print error to log and exit NOK
##

function proc::exit_error {
    local message="${1}"
    local exit_code="${2:-1}"

    log::trace "${FUNCNAME[0]}: ${*} - Logging ERROR and exiting"

    proc::exit_log "${message}" ERROR "${exit_code}"
}


function proc::die { proc::exit_error "${@}"; }


##
## Error out when input is false
##

function proc::die_if_false {
    local value="${1:-""}"
    local message="${2:-""}"
    local severity="${3:-"ERROR"}"
    local exit_code="${4:-1}"

    log::trace "${FUNCNAME[0]}: ${*} - Error out when input is false"

    if var::is_false "${value}"
    then
        proc::exit_log "${message}" "${severity}" "${exit_code}"
    fi
}


##
## Error out if input is true
##

function proc::die_if_true {
    local value=${1:-}
    local message=${2:-}
    local severity="${3:-"ERROR"}"
    local exit_code="${4:-1}"

    log::trace "${FUNCNAME[0]}: ${*} - Error out when input is true"

    if var::is_true "${value}"
    then
        proc::exit_log "${message}" "${severity}" "${exit_code}"
    fi
}


##
## Error out if input is empty
##

function proc::die_if_empty {
    local value=${1:-}
    local message=${2:-}
    local severity="${3:-"ERROR"}"
    local exit_code="${4:-1}"

    log::trace "${FUNCNAME[0]}: ${*} - Error out when input is empty"

    if var::is_empty "${value}"
    then
        proc::exit_log "${message}" "${severity}" "${exit_code}"
    fi
}
