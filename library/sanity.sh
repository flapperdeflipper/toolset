#!/usr/bin/env bash
################################################################################
## Sanity checker                                                             ##
################################################################################
# shellcheck disable=SC2312

function sanity::check {
    local input="${1}"

    log::trace "${FUNCNAME[*]}: Retrieving and importing sanity checks"

    ## Source all sanity checks
    for testfile in "${SANITY_CHECK_PATH:-}"/*.sh
    do
        # Verbose output
        var::has_value "${input}" \
            && log::info "Loading file ${testfile}"

        # shellcheck source=/dev/null
        source "${testfile}"
    done

    local failed=0

    log::info "Running sanity checks"

    ## Run all defined sanity checks
    for sanity_check in $( \
        declare -F \
        |  awk '/sanity::check::/ {print $NF}' \
        | grep -v '^sanity::check$' \
        | sort -u \
    )
    do
        var::has_value "${input}" \
            && log::info "Running check ${sanity_check}"

        if ! "${sanity_check}"
        then
            ((failed++));
        fi

        ## Remove function after use
        unset -f "${sanity_check}"

    done

    if var::ne "${failed}" 0
    then
        log::error "${FUNCNAME[*]}: Not all sanity checks succeeded"
        return 1
    fi

    return 0
}
