#!/usr/bin/env bash
# vi: ft=bash
# shellcheck shell=bash disable=SC2048

################################################################################
## ECR                                                                        ##
################################################################################

##
## List available registries
##

function aws::ecr::list_repos {
    local arguments=("${@}")

    aws::cli ecr describe-repositories ${arguments[*]} \
        | jq -r '.repositories[] | [.repositoryName, .repositoryUri] | @tsv' \
        | column -t
}


##
## List all tags for a registry
##

function aws::ecr::list_tags {
    local registry="${1}"; shift
    local arguments=("${@}")

    local account_id

    if ! account_id="$( aws::sts::account_id ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Failed to get current account ID from aws"
        return 1
    fi

    local arn="arn:aws:ecr:${region}:${account_id}:repository/${registry}"

    if ! aws::cli ecr list-tags-for-resource \
        --resource-arn="${arn}" \
        ${arguments[*]}
    then
        log::error "${FUNCNAME[0]}: Failed to get tags for ${registry}"
        return 1
    fi
}


##
## List all findings of the ECR security scan of a registry
##

function aws::ecr::list_findings {
    local registry="${1}"; shift
    local tag="${1:-master}"; shift || true
    local arguments=("${@}")

    if ! aws::cli ecr describe-image-scan-findings \
        --repository-name "${registry}" \
        --image-id "imageTag=${tag}" \
        ${arguments[*]}
    then
        log::error "${FUNCNAME[0]}: Failed to retrieve ECR findings for ${registry}:${tag}"
        return 1
    fi
}
