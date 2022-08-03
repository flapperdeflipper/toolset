#!/usr/bin/env bash
# vi: ft=bash
# shellcheck shell=bash disable=SC2048

################################################################################
## EC2                                                                        ##
################################################################################

##
## Query instance
##

function aws::ec2::query_instances {
    local query="${1}"; shift
    local arguments=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving instance id ${instance}"

    if ! aws::cli ec2 describe-instances --query "${query}" ${arguments[*]}
    then
        log::error "${FUNCNAME[0]}: Failed to run ec2 describe-instances with query ${query}"
        return 1
    fi

    return 0
}


##
## Query instance status
##

function aws::ec2::query_instance_status {
    local instance="${1}"; shift
    local query="${1}"; shift
    local arguments=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving instance status id ${instance}"

    if ! aws::cli ec2 describe-instance-status \
        --query "${query}" \
        "${arguments[*]}"
    then
        log::error "${FUNCNAME[0]}: Failed to run ec2 describe-instances with query ${query}"
        return 1
    fi

    return 0
}

##
## Retrieve the ip address for an ec2 instance id
##

function aws::ec2::get_ip_for_instance {
    local instance="${1}"; shift
    local arguments=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving ip address for instance id ${instance}"

    if ! aws::ec2::query_instances 'Reservations[*].Instances[*].[PrivateIpAddress]' \
        --instance-ids "${instance}" \
        --output=text \
        ${arguments[*]}
    then
        log::error "${FUNCNAME[0]}: Failed to query instance ${instance}"
        return 1
    fi

    return 0
}


##
## Retrieve the ip address for an ec2 instance id
##

function aws::ec2::ip_to_id {
    local ip_address="${1}"; shift
    local arguments=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving instance id for ip address ${ip_address}"

    if ! aws::ec2::query_instances 'Reservations[].Instances[]' \
        --filter "Name=private-ip-address,Values=${ip_address}" \
        ${arguments[*]} \
        | jq -r '.[0].InstanceId'
    then
        log::error "${FUNCNAME[0]}: Failed to get instance id for ip address ${ip_address}"
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

    if ! aws::ec2::query_instances 'Reservations[*].Instances[*].[PrivateDnsName]' \
        --instance-ids "${instance}" \
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
    local hostname="${1}"; shift
    local arguments=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving instance id for hostname ${hostname}"

    if ! aws::ec2::query_instances 'Reservations[].Instances[]' \
        --filter "Name=private-dns-name,Values=$hostname" \
        ${arguments[*]} \
        | jq -r '.[0].InstanceId'
    then
        log::error "${FUNCNAME[0]}: Failed to get instance id for hostname ${hostname}"
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

##
## Get the AZ for an instance
##

function aws::ec2::get_az {
    local instance="${1}"; shift
    local arguments=("${@}")

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving az for instance id ${instance}"

    if ! aws::ec2::query_instance_status \
        "${instance_id}" \
        "InstanceStatuses[*].AvailabilityZone" \
        --output=text \
        "${arguments[@]}" \
        | jq -r '.[0]'
    then
        log::error "${FUNCNAME[0]}: Failed to retrieve availability zone for ${instance}"
        return 1
    fi

    return 0
}

##
## Push an SSH public key for an SSH instance
##

function aws::ec2::push_public_key {
    local instance="${1}"; shift
    local username="${1}"; shift
    local pubkey="${1}"; shift
    local arguments=("${@}")

    if ! instance_id="$( aws::ec2::instance_id "${instance}" ${arguments[*]} )"
    then
        log::error "${FUNCNAME[0]}: Invalid input for ${instance}: Input is not an id, not an internal ip and not a DNS name..."
        return 1
    fi

    if ! availability_zone="$( aws::ec2::get_az "${instance_id}" "${arguments[*]}" )"
    then
        log::error "${FUNCNAME[0]}: Failed to get availability zone for instance ${instance}"
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Pushing public ssh key for ec2 instance ${instance}"

    if ! aws::cli ec2-instance-connect send-ssh-public-key \
         --instance-id "${instance_id}" \
         --availability-zone "${availability_zone}" \
         --instance-os-user "${username}" \
         --ssh-public-key "file://${pubkey}" \
         "${arguments[@]}"
    then
        log::error "${FUNCNAME[0]}: Failed to push public key for ec2-instance-connect instance ${instance}"
        return 1
    fi
}

