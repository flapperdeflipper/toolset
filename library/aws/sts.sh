#!/usr/bin/env bash
# vi: ft=bash
# shellcheck shell=bash disable=SC2048


################################################################################
## STS                                                                        ##
################################################################################

function aws::sts::caller_identity {
    local arguments=("${@}")
    aws::cli sts get-caller-identity "${arguments[*]}"
}

function aws::sts::user_id {
    local arguments=("${@}")

    aws::sts::caller_identity "${arguments[*]}" \
        | jq -r '.UserId | split(":")[1]'
}

function aws::sts::account_id {
    local arguments=("${@}")

    aws::sts::caller_identity "${arguments[*]}" \
        | jq -r '.Account'
}

function aws::sts::user_arn {
    local arguments=("${@}")

    aws::sts::caller_identity "${arguments[*]}" \
        | jq -r '.Arn'
}
