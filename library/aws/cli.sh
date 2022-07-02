#!/usr/bin/env bash
# vi: ft=bash
# shellcheck shell=bash disable=SC2048


##
## A wrapper around AWS cli
##

function aws::cli {
    [ "${#}" -ge 1 ] || return 2

    depends::check "aws" || return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running aws cli with arguments: ${*}"

    aws "${@}"
}
