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

        return 0
    fi

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
