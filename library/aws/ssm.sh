#!/usr/bin/env bash
# vi: ft=bash
# shellcheck shell=bash disable=SC2048

################################################################################
## Session managers                                                           ##
################################################################################

##
## List ssm instances available
##

function aws::ssm::list {
    local instance="${1}"; shift
    local arguments=("${@}")

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: ${*} - Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Retriving instance info for instance ${instance}"

    if ! aws::cli ssm describe-instance-information \
        --query "InstanceInformationList[*].{Name:ComputerName,Id:InstanceId,IPAddress:IPAddress}" \
        --output text \
        ${arguments[*]}
    then
        log::error "${FUNCNAME[0]}: Failed to run ssm describe-instance-information"
        return 1
    fi

    return 0
}

##
## Setup session
##

function aws::ssm::session {
    local instance="${1}"; shift
    local arguments=("${@}")

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Opening ssm session to instance ${instance}"

    if ! aws::cli ssm start-session \
            --target "${instance}" \
            --document-name SSM-SessionManagerRunShell \
            ${arguments[*]}
    then
        log::error "${FUNCNAME[0]}: Failed to create ssm session for ${instance}"
        return 1
    fi
}

##
## Open SSH session
##

function aws::ssm::ssh {
    local instance="${1}"; shift
    local arguments=("${@}")

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Opening ssh session to instance ${instance}"

    ssh "${instance_id}" \
        -o ProxyCommand="bash -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p' ${arguments[*]}\""
}


##
##
##

function aws::ssm::scp {
    local instance="${1}"
    local arguments=("${*:2}")

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Secure copy-ing to instance ${instance} with arguments ${arguments[*]}"

    scp "${instance_id}" \
        -o ProxyCommand="bash -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p' ${arguments[*]}\""
}


##
## Setup SSH tunnel
##

function aws::ssm::tunnel {
    local instance="${1}"; shift
    local local_port="${1}"; shift
    local remote_port="${1}"; shift
    local arguments=("${@}")

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Opening SSH tunnel from local port ${local_port} to instance ${instance} on port ${remote_port}"

    if ! aws::cli ssm start-session \
        --target "${instance_id}" \
        --document-name AWS-StartPortForwardingSession \
        --parameters \
            "{\"portNumber\":[\"${remote_port}\"],\"localPortNumber\":[\"${local_port}\"]}" \
        ${arguments[*]}
    then
        log::error "${FUNCNAME[0]}: Failed to create ssm session for ${instance}"
        return 1
    fi

    return 0
}


##
## Run command
##

function aws::ssm::run_command {
    local instance="${1}"; shift
    local command="${1}"; shift
    local arguments=("${@}")

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Sending remote command to instance ${instance}: ${command}"

    if ! aws::cli ssm send-command \
        --instance-ids "${instance_id}" \
        --document-name "AWS-RunShellScript" \
        --parameters commands="${command}" \
        --output text \
        ${arguments[*]}
    then
        log::error "${FUNCNAME[0]}: Failed to run command for ${instance}"
        return 1
    fi

    return 0
}


##
## Retrieve an SSM parameter
##

function aws::ssm::parameter::get() {
    local key="${1}";   shift
    local -a arguments=("${@}")

    local parameter=""

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving ssm parameter ${key}"

    if ! parameter="$( \
        aws::cli ssm get-parameter  \
            --name "${key}" \
            --output text \
            --query "Parameter.Value" \
            ${arguments[*]} \
    )" \
    || [[ -z "${parameter:-}" ]]
    then
        log::error "Failed to retrieve ssm parameter ${key}"
        return 1
    fi

    echo "${parameter}"
}

##
## Store an SSM parameter
##

function aws::ssm::parameter::put() {
    local path="${1}"; shift
    local value="${1}"; shift
    local -a arguments=("${@}")

    local ssm_args=(
        --name "${path}"
        --value "${value}"
        --type SecureString
        "${arguments[@]}"
    )

    log::info "${FUNCNAME[0]}: Checking of ssm parameter ${path} exists"

    if ! aws::ssm::parameter::get "${path}" "${arguments[@]}" > /dev/null 2>&1
    then
        log::info "Creating ssm parameter ${path}"
    else
        log::info "Updating ssm parameter ${path}"
        ssm_args+=(--overwrite)
    fi

    if ! chronic aws ssm put-parameter ${ssm_args[*]}
    then
        log::error "Failed to create SSM parameter ${path}"
        return 1
    fi

    return 0

}

##
## List all ssm parameters
##
function aws::ssm::parameter::list() {
    local path="${1}"; shift
    local -a arguments=("${@}")

    aws::cli ssm get-parameters-by-path \
        --path "${path}" \
        --recursive  \
        --query 'Parameters[].[Name]' \
        --output text \
        ${arguments[*]}
}

