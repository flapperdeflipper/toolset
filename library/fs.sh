#!/usr/bin/env bash

################################################################################
## FS:: Filesystem helpers                                                    ##
################################################################################

##
## Check if directory and existent
##

function fs::is_dir {
    local directory="${1:-""}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if directory ${directory} exists"

    if [[ -d "${directory}" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if file and existent
##

function fs::is_file {
    local file="${1:-""}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if file ${file} exists"

    if [[ -f "${file}" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if device and existent
##

function fs::is_device {
    local device="${1:-""}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if device ${device} exists"

    if [[ -b "${device}" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if socket and existent
##

function fs::is_socket {
    local socket="${1:-""}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if socket ${socket} exists"

    if [[ -S "${socket}" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if pipe and existent
##

function fs::is_pipe {
    local pipe="${1:-""}"

    log::trace "${FUNCNAME[0]}: Checking if pipe ${pipe} exists"

    if [[ -p "${pipe}" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if symlink and existent
##

function fs::is_link {
    local file="${1:-""}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if symlink ${file} exists"

    if [[ -L "${file}" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if executable and existent
##

function fs::is_executable {
    local file="${1:-""}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if file ${file} is executable"

    if [[ -x "${file}" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if existent
##

function fs::exists {
    local file="${1:-""}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if ${file} exists"

    if [[ -e "${file}" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if file matches regex
##

function fs::is_regex {
    local file="${1:-""}" ; shift
    local regex="${1:-""}"; shift
    local arguments="${*:--E}"

    fs::exists "${file}" || return 1

    log::trace "${FUNCNAME[0]}: ${*} - Checking if file ${file} matches regex ${regex}"

    # shellcheck disable=SC2086
    if grep -q ${arguments} "${regex}" "${file}"
    then
        return 0
    fi

    return 1
}

##
## Check how many times a regex occurs in a file
##

function fs::regex_count {
    local file="${1:-""}"; shift
    local regex="${1:-""}"; shift
    local arguments="${*:--E}"

    fs::exists "${file}" || return 1

    log::trace "${FUNCNAME[0]}: ${*} - Checking how many times regex ${regex} matches in file ${file}"

    # shellcheck disable=SC2086
    grep -c ${arguments} "${regex}" "${file}"
}
