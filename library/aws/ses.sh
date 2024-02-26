#!/usr/bin/env bash
# vi: ft=bash
# shellcheck shell=bash disable=SC2048,SC2086


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
