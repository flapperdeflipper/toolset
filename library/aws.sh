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


################################################################################
## STS                                                                        ##
################################################################################

function aws::sts::caller_identity {
    local arguments=("${@}")
    aws::cli sts get-caller-identity ${arguments[*]}
}

function aws::sts::user_id {
    local arguments=("${@}")

    aws::sts::caller_identity ${arguments[*]} \
        | jq -r '.UserId'
}

function aws::sts::account_id {
    local arguments=("${@}")

    aws::sts::caller_identity ${arguments[*]} \
        | jq -r '.Account'
}

function aws::sts::user_arn {
    local arguments=("${@}")

    aws::sts::caller_identity ${arguments[*]} \
        | jq -r '.Arn'
}


################################################################################
## EC2                                                                        ##
################################################################################

##
## Retrieve the ip address for an ec2 instance id
##

function aws::ec2::get_ip_for_instance {
    local instance="${1}"; shift
    local arguments=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving ip address for instance id ${instance}"

    if ! aws::cli ec2 describe-instances \
        --instance-ids "$instance" \
        --query "Reservations[*].Instances[*].[PrivateIpAddress]" \
        --output=text \
        ${arguments[*]}
    then
        log::error "${FUNCNAME[0]}: Failed to run ec2 describe-instances for ${instance}"
        return 1
    fi

    return 0
}


##
## Retrieve the ip address for an ec2 instance id
##

function aws::ec2::ip_to_id {
    local instance="${1}"; shift
    local arguments=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving instance id for ip address ${instance}"

    if ! aws::cli ec2 describe-instances \
            --query 'Reservations[].Instances[]' \
            --filters "Name=private-ip-address,Values=${instance}" \
            ${arguments[*]} \
        | jq -r '.[0].InstanceId'
    then
        log::error "${FUNCNAME[0]}: Failed to run ec2 describe-instances for ${instance}"
        return 1
    fi

    return 0
}


##
## Retrieve the hostname for an ec2 instance id
##

function aws::ec2::id_to_name {
    local instance="${1}"; shift
    local arguments=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving hostname for instance id ${instance}"

    if ! aws::cli ec2 describe-instances \
            --instance-ids "${instance}" \
            --query "Reservations[*].Instances[*].[PrivateDnsName]"  \
            ${arguments[*]} \
        | jq -r '.[0][0][0]'
    then
        log::error "${FUNCNAME[0]}: Failed to run ec2 describe-instances for ${instance}"
        return 1
    fi

    return 0
}


##
## Retrieve the instance id for an ec2 instance hostname
##

function aws::ec2::name_to_id {
    local instance="${1}"; shift
    local arguments=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving instance id for hostname ${instance}"

    if ! aws::cli ec2 describe-instances \
            --query 'Reservations[].Instances[]' \
            --filters "Name=private-dns-name,Values=$instance" \
            ${arguments[*]} \
        | jq -r '.[0].InstanceId'
    then
        log::error "${FUNCNAME[0]}: Failed to run ec2 describe-instances for ${instance}"
        return 1
    fi

    return 0
}


##
## Get the instance id
##

function aws::ec2::instance_id {
    local instance="${1}"; shift
    local arguments=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving the instance id for input ${instance}"

    if string::contains compute.internal "${instance}"
    then
        ## instance is an instance private dns name
        aws::ec2::name_to_id "${instance}" ${arguments[*]}

    elif string::startswith "i-" "${instance}"
    then
        ## instance is an instance id
        echo "${instance}"

    elif net::is_ip4 "${instance}"
    then
        ## instance is an instance private ip address
        aws::ec2::ip_to_id "${instance}" ${arguments[*]}
    else
        return 1
    fi
}


##
## Get console output of an instance
##

function aws::ec2::console_output {
    local instance="${1}"; shift
    local arguments=("${@}")

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving console output for instance ${instance}"

    if ! aws::cli ec2 get-console-output \
        --instance-id "${instance_id}" \
        --latest \
        --output text \
        ${arguments[*]}
    then
        log::error "${FUNCNAME[0]}: Failed to retrieve console output for ${instance}"
        return 1
    fi

    return 0
}


##
## Return web link for instances
##

function aws::ec2::weblink {
    local instance="${1}"; shift
    local region="${1:-"${AWS_REGION:-"${AWS_DEFAULT_REGION:-"eu-west-1"}"}"}"; shift || true
    local arguments=("${@}")

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Generating webconsole link for instance ${instance}"

    printf "https://%s.console.aws.amazon.com/ec2/v2/home?region=%s#InstanceDetails:instanceId=%s" "${region}" "${region}" "${instance}"
}


##
## Terminate instance
##

function aws::ec2::terminate {
    local instance="${1}"; shift
    local autoscaled="${1}"; shift
    local arguments=("${@}")

    local -a cmd

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Terminating instance ${instance} (autoscaled=${autoscaled})"

    if var::eq "${autoscaled}" 0
    then
        cmd=(
            aws::cli ec2
            terminate-instances
            --instance-ids "${instance_id}"
            "${arguments[*]}"
        )

    elif var::eq "${autoscaled}" 1
    then
        cmd=(
            aws::cli autoscaling
            terminate-instance-in-auto-scaling-group
            --instance-id "${instance_id}"
            --no-should-decrement-desired-capacity
            "${arguments[*]}"
        )
    else
        log::error "${FUNCNAME[0]}: Failed to determine if autoscaling group should be adjusted!"
        return 1
    fi

    if ! "${cmd[@]}"
    then
        log::error "${FUNCNAME[0]}: Failed to terminate instance ${instance}"
        return 1
    fi

    return 0
}


##
## Reboot instance
##

function aws::ec2::reboot {
    local instance="${1}"; shift
    local arguments=("${@}")

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Rebooting instance ${instance}"

    if ! aws::cli ec2 reboot-instances \
         --instance-ids "$instance_id" \
        ${arguments[*]}
    then
        log::error "${FUNCNAME[0]}: Failed to reboot instance ${instance}"
        return 1
    fi

    return 0
}

##
## List spot instances
##

function aws::ec2::list_spot {
    if ! aws::cli ec2 describe-spot-instance-requests ${arguments[*]} \
        | jq -r '
            # extract instances as a flat list.
            [.SpotInstanceRequests | .[]
            # remove unwanted data
            | {
                State,
                statusCode: .Status.Code,
                type:       .LaunchSpecification.InstanceType,
                SpotPrice:  .SpotPrice,
                created:    .CreateTime,
                SpotInstanceRequestId }
            ]
            # lowercase keys (for predictable sorting, optional)
            | [.[]| with_entries( .key |= ascii_downcase ) ]
            | (.[0] |keys_unsorted | @tsv) # print headers
            , (.[]|.|map(.) |@tsv)         # print table
            ' \
        | column -t
    then
        log::error "${FUNCNAME[0]}: Failed to retrieve spot instances"
        return 1
    fi
}


##
## Return info for instance
##

function aws::ec2::info {
    local instance="${1}"; shift
    local arguments=("${@}")

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving ec2 info table for instance ${instance}"

    if ! aws::cli ec2 describe-instances \
        --instance-ids "${instance}" \
        --output=table \
        ${arguments[*]}
    then
        log::error "${FUNCNAME[0]}: Failed to run ec2 describe-instances for ${instance}"
        return 1
    fi

    return 0
}


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

    if ! aws ssm describe-instance-information \
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

function aws:ssm::run_command {
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


################################################################################
## SES                                                                        ##
################################################################################

function aws::ses::print_records {
    local domain="${1}"
    local verification="${2}"
    local tokens=("${3}")

    cat <<EOF

    The domain has been added to Amazon Simple Email Service!
    Please add the following DNS records to the ${domain} zone:

    SES Verification record:

        _amazonses.${domain} TXT "${verification}"

    DKIM CNAME records:

EOF
    for token in "${tokens[@]}"
    do
        echo -e "\t\t${token}._domainkey.${domain} CNAME ${token}.dkim.amazonses.com"
    done

    echo
}

function aws::ses::whitelist_domain {
    local domain="${1}"; shift
    local arguments=("${@}")
    local output

    if ! output="$(
        aws::cli ses verify-domain-identity \
            --domain "${domain}" \
            ${arguments[*]} \
        )"
    then
        log::error "${FUNCNAME[0]}: Failed to create SES validation for domain ${domain}"
        return 1
    fi

    if ! verification="$( jq -r '.VerificationToken' <<< "${output}" )"
    then
        log::error "${FUNCNAME[0]}: Failed to retrieve SES verification token"
        return 1
    fi

    if ! tokens=("$( jq -r '.DkimTokens | join(" ")' <<< "${output}" )")
    then
        log::error "${FUNCNAME[0]}: Failed to retrieve dkim tokens"
        return 1
    fi

    aws::ses::print_records "${domain}" "${verification}" "${tokens[@]}"
}


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
