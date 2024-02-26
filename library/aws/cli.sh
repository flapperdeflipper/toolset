#!/usr/bin/env bash
# vi: ft=bash
# shellcheck shell=bash disable=SC2048,SC2312


##
## A wrapper around AWS cli
##

function aws::cli {
    [[ "${#}" -ge 1 ]] || return 2

    depends::check "aws" || return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running aws cli with arguments: ${*}"

    command aws "${@}"
}


##
## Check if assumed role is admin
##
function aws::check_for_admin() {
    local role=""

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving caller identity"

    # shellcheck disable=SC2086
    if ! role="$( aws::cli sts get-caller-identity ${*} | jq -r '.Arn' )" \
    || [[ -z "${role}" ]]
    then
        log::error "Failed to retrieve caller identy from AWS api"
        return 1
    fi

    log::info "${FUNCNAME[0]}: Checking if user is admin"

    if [[ ! "${role}" =~ "Administrator" ]]
    then
        log::error "You need to be AWS administrator to use this tool"
        return 1
    fi

    return 0
}
