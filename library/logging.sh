#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2155

################################################################################
## Color utils                                                                ##
################################################################################

if [[ -t 1 ]] && tput setaf 1 &> /dev/null
then
    tput sgr0; # reset colors

    bold="$( tput bold )"
    black="$( tput setaf 0 )"
    red="$( tput setaf 1 )";
    green="$( tput setaf 2 )"
    yellow="$( tput setaf 3 )"
    blue="$( tput setaf 4 )"
    magenta="$( tput setaf 5 )"
    cyan="$( tput setaf 6 )"
    white="$( tput setaf 007 )"
    orange="$( tput setaf 166 )"
    purple="$( tput setaf 125 )"
    violet="$( tput setaf 61 )"
    reset="$( tput sgr0 )"
else
    bold='\e[1m'
    black='\e[0m'
    red='\033[0;31m'
    green='\e[0;32m'
    yellow='\e[1;33m'
    blue='\e[0;34m'
    magenta='\e[1;35m'
    cyan='\e[0;36m'
    white='\e[1;37m'
    orange='\e[0;33m'
    purple='\e[0;35m'
    violet='\e[1;35m'
    reset='\e[0m'
fi


################################################################################
## Logger util                                                                ##
################################################################################

function log::logger {
    local message="${1}"
    local level="${2:-INFO}"
    local cr="${3:-1}"

    ## Skip logs with trace level if trace flag is not set
    if [[ "${level}" == "TRACE" ]] && [[ "${TRACE}" != 1 ]]
    then
        return 0
    fi

    ## Skip logging if silent flag is set
    if  [[ -n "${SILENT}" ]] && [[ "${SILENT}" == 1 ]]
    then
        return 0
    fi

    ## Check if cr is 1
    if [ "${cr}" == 1 ];
    then
        linefeed='\n'
    else
        linefeed=''
    fi

    local timestamp
          timestamp="$( date '+%Y-%m-%d %H:%M:%S' )"
    local color

    case "${level}" in
        ERROR)   color=${bold}${red}    ;;
        INFO)    color=${bold}${green}  ;;
        WARNING) color=${bold}${yellow} ;;
        TRACE)   color=${bold}${purple} ;;
        DEBUG)   color=${bold}${blue}   ;;
        *)       color=${bold}${white}  ;;
    esac

    local -a logline=(
        "${color}[+]${reset}"
        "${bold}${white}%s${reset}"
        "-"
        "[${color}%s${reset}]"
        "-"
        "${bold}${white}%s${reset}${linefeed}"
    )

    printf \
        "${logline[*]}" \
        "${timestamp}" \
        "${level}" \
        "${message}" \
        &> /dev/stderr
}


################################################################################
## Log functions                                                              ##
################################################################################

####################
## NOK            ##
####################

function log::err {
    local message="${1}"
    local cr="${2:-1}"

    log::logger "${message}" ERROR "${cr}"
}

function log::error {
    log::err "${@}"
}

function log::critical {
    log::err "${@}"
}


####################
## OK             ##
####################

function log::info {
    local message="${1}"
    local cr="${2:-1}"

    log::logger "${message}" INFO "${cr}"
}

function log::ok {
   log::info "${@}"
}

function log::log {
   log::info "${@}"
}


####################
## TRACE          ##
####################

function log::trace {
    local message="${1}"
    local cr="${2:-1}"

    log::logger "${message}" TRACE "${cr}"
}


####################
## DEBUG          ##
####################

function log::debug {
    local message="${1}"
    local cr="${2:-1}"

    log::logger "${message}" DEBUG "${cr}"
}


####################
## WARNING        ##
####################

function log::warn {
    local message="${1}"
    local cr="${2:-1}"

    log::logger "${message}" WARNING "${cr}"
}

function log::warning {
    log::warn "${@}"
}


################################################################################
## Generic log functions                                                      ##
################################################################################

function log::input {
    local message="${1}"
    local cr="${2:-1}"

    log::logger "${message}" INPUT "${cr}"
}

function log::output {
    local message="${1}"
    local cr="${2:-1}"

    log::logger "${message}" OUTPUT "${cr}"
}

################################################################################
## Stdout to logger                                                           ##
################################################################################

function log::stdin {
    local level="${1:-INPUT}"
    local cr="${2:-1}"

    while read -r line
    do
        log::logger "${line}" "${level}" "${cr}"
    done < /dev/stdin
}
