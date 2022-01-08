#!/usr/bin/env bash

##
## Request confirmation
##

function interact::prompt_bool {
    local OPTIND
    local opts
    local input

    log::trace "${FUNCNAME[0]}: ${*} - Asking the user for confirmation"

    local prompt="Continue?"
    declare -A opts

    while getopts ":y" opt
    do
        case "${opt}" in
            y) opts[default_yes]=1 ;;
            *) log::warning "${FUNCNAME[0]}: Unknown option specified: ${opt}" ;;
        esac
    done

    shift $(( OPTIND - 1 ))

    if [[ "${opts[default_yes]:-""}" ]]
    then
        prompt+=" [Y/n]"
    else
        prompt+=" [y/N]"
    fi

    if [[ -z "${BATS_TEST_FILENAME}" ]]
    then
        ## Remove all input that was accidentally inserted during wait
        read -r -d '' -t 0.1 -n 10000
    fi

    log::input "${prompt} -> " 0
    read -r input

    # Explicit yes
    if [[ $input =~ ^[Yy]$ ]]
    then
        return 0
    fi

    # Implicit yes
    if [[ $input == "" ]] && [[ "${opts[default_yes]:-""}" ]]
    then
        return 0
    fi

    # No
    return 1
}


##
## Input
##

function interact::prompt_response {
    [[ "${#}" == 0 ]] \
        && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2

    declare def_arg response
    response=""
    def_arg="${2}"

    log::trace "${FUNCNAME[0]}: ${*} - Asking the user for input"

    if [[ -z "${BATS_TEST_FILENAME}" ]]
    then
        ## Remove all input that was accidentally inserted during wait
        read -r -d '' -t 0.1 -n 10000
    fi

    while :; do
        log::input "${1} "

        [[ -n "${def_arg}" ]] && [[ "${def_arg}" != "-" ]] && printf "[%s] " "${def_arg}"

        read -r response
        [[ -n "${response}" ]] && break

        if [[ -z "${response}" ]] && [[ -n "${def_arg}" ]]; then
            response="${def_arg}"
            break
        fi
    done

    [[ "${response}" == "-" ]] && response=""

    printf "%s\n" "${response}"
}


##
## Check if a specific argument is given
##

function interact::in_args {
    local arguments="${1}";  shift
    local input="${*}"

    for argument in ${arguments};
    do
        if var::matches "${input}" "${argument}"
        then
            return 0
        fi
    done

    return 1
}


##
## Check if -h or --help is given in arguments
##

function interact::usage {
    local input="${*}"

    if interact::in_args "-h --help" "${input}"
    then
        return 0
    fi

    return 1
}




