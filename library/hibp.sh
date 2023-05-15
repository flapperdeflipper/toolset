#!/usr/bin/env bash

##
## Check is a password is known by hibp
##

function hibp::is_safe {
    local password="${1:-}"; shift || return 2
    local -i count=0

    log::trace "${FUNCNAME[0]}: ****** ${*} - Checking is password is safe"

    if ! count="$( hibp::check "${password}" 1 )"
    then
        log::warning "${FUNCNAME[0]}: Lookup failed"
        return 2
    fi

    if var::ne "${count}" 0
    then
        return 1
    fi

    return 0
}


##
## Check password against hibp api
##

function hibp::check {
    local password="${1:-}"; shift || return 1
    local -i silent="${1:-0}"

    log::trace "${FUNCNAME[0]}: ****** ${*} Checking password agains hibp api"

    local response
    local -i status
    local -i count=0

    if var::is_empty "${password}"
    then
        log::error "${FUNCNAME[0]}: Password empty"
        return 1
    fi

    # Hash the password
    password="$( \
        echo -n "${password}" \
        | sha1sum \
        | tr '[:lower:]' '[:upper:]' \
        | awk -F ' ' '{ print $1 }'
    )"

    log::trace "Password SHA1: ${password}"

    local arguments=""

    if var::has_value "${TRACE}" \
    && var::eq "${TRACE}" 1
    then
        arguments="-v"
    else
        arguments="--silent"
    fi

    if ! response="$( \
        curl \
            ${arguments} \
            --show-error \
            --write-out '\n%{http_code}' \
            --request GET \
            "https://api.pwnedpasswords.com/range/${password:0:5}"
    )"
    then
        log::trace "Response: ${response}"
        log::error "${FUNCNAME[0]}: Error contacting hibp api"
        return 1
    fi

    status="${response##*$'\n'}"
    response="${response%"$status"}"

    log::debug "Uri: /range/${password:0:5}"
    log::debug "Status code: ${status}"
    log::debug "API response: ${response}"

    if var::eq "${status}" 429
    then
        log::error "HIBP Rate limit exceeded."
        return 1
    fi

    if var::eq "${status}" 503
    then
        log::error "HIBP Service unavailable."
        return 1
    fi

    if var::ne "${status}" 200
    then
        log::error "${FUNCNAME[0]}: Fault response from api"
        return 1
    fi

    for item in ${response}
    do
        if var::equals "${password:5:35}" "${item%%:*}"
        then
            count="$( echo "${item#*:}" | tr -d '\r' )"

            if var::eq "${silent}" 0
            then
                log::warning "Password was found ${count} times in hibp db"
            fi

            printf '%d\n' "${count}"

            return 0
        fi
    done

    if var::ne "${silent}" 1
    then
        log::info "Password was not found in hibp db"
    fi

    printf "0"

    return 0
}
