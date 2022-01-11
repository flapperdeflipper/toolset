#!/usr/bin/env bash

export TRACE=""
export SILENT=0


# Output failures message for functions that are not returning exit status 0
# ref: https://github.com/bash-utilities/trap-failure/

# shellcheck disable=SC2154
function debug::handle_error() {
    local -n lineno="${1:-LINENO}"
    local -n bash_lineno="${2:-BASH_LINENO}"

    local last_command="${3:-${BASH_COMMAND}}"
    local code="${4:-0}"

    ## Workaround for read EOF combo tripping traps
    ((code)) || {
      return "${code}"
    }

    local -a output_array=(
        "Script:         ${TOOLSET_BIN_PATH}/${TOOLSET_SCRIPT_NAME}"
        "Exitcode:       ${code}"
        "Line history:   [${lineno} ${bash_lineno[*]}]"
        "Function trace: [${FUNCNAME[*]}]"
        "Output array:   ${last_command}"
    )

    if [[ "${#BASH_SOURCE[@]}" -gt 1 ]]
    then
        output_array+=('source_trace:')

        for item in "${BASH_SOURCE[@]}"
        do
            output_array+=("  - ${item}")
        done
    else
        output_array+=("source_trace: [${BASH_SOURCE[*]}]")
    fi

    printf "${red}"
    printf '\n'
    printf "\t>>> Error during execution\n"
    printf '\n'
    printf '\t%s\n' "${output_array[@]}" >&2
    printf '\n'
    printf "${reset}"

    exit "${code}"
}


function debug::set_debug {
    export TRACE=1

    trap 'debug::handle_error "LINENO" "BASH_LINENO" "${BASH_COMMAND}" "${?}"' ERR
}


function debug::unset_debug {
    export TRACE=""

    trap - ERR
}


function debug::set_silent {
    export SILENT=1
}


function debug::unset_silent {
    export SILENT=0
}
