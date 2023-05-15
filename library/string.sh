#!/usr/bin/env bash

################################################################################
## String manipulation                                                        ##
################################################################################

##
## Convert a string to lowercase
##

function string::lower {
    [[ "${#}" -le 1 ]] || return 2

    local string="${1:-}"

    if var::is_empty "${string}" && var::is_stdin
    then
        string="$( < /dev/stdin )"

    elif var::is_empty "${string}"
    then
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Converting string to lowercase"

    printf "%s" "${string,,}"
}


##
## Convert a string to lowercase
##

function string::upper {
    [[ "${#}" -le 1 ]] || return 2

    local string="${1:-}"

    if var::is_empty "${string}" && var::is_stdin
    then
        string="$( < /dev/stdin )"
    elif var::is_empty "${string}"
    then
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Converting string to uppercase"

    printf "%s" "${string^^}"
}


##
## Replace a substring in a string
##

function string::replace {
    [ "${#}" -ne 3 ] && return 2

    local needle="${1}"
    local replacement="${2}"
    local haystack="${3}"

    log::trace "${FUNCNAME[0]}: ${*} - Replacing needle for string in haystack"

    printf "%s" "${haystack//${needle}/${replacement}}"
}


##
## Return the lenght of a string
##

function string::length {
    [[ "${#}" -le 1 ]] || return 2

    local string="${1:-}"

    if var::is_empty "${string}" && var::is_stdin
    then
        string="$( < /dev/stdin )"
    elif var::is_empty "${string}"
    then
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving the length of string"

    printf "%s" "${#string}"
}


##
## Strip carriage return from string
##

function string::chomp {
    [[ "${#}" -le 1 ]] || return 2

    local string="${1:-}"

    if var::is_empty "${string}" && var::is_stdin
    then
        string="$( < /dev/stdin )"
    elif var::is_empty "${string}"
    then
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Stripping whitespace from string"

    printf "%s" "${string/"$'\n'"/}"
}


##
## Remove all superfluous whitespace
##

function string::trim {
    [[ "${#}" -le 1 ]] || return 2

    local string="${1:-}"

    if var::is_empty "${string}" && var::is_stdin
    then
        string="$( < /dev/stdin )"
    elif var::is_empty "${string}"
    then
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Stripping whitespace from string"

    printf "%s\n" "$( xargs <<< "${string}" )"
}


##
## Strip a char from the left side of a string
##

function string::lstrip {
    [[ "${#}" -le 1 ]] || return 2

    local string="${1:-}"

    if var::is_empty "${string}" && var::is_stdin
    then
        string="$( < /dev/stdin )"
    elif var::is_empty "${string}"
    then
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Stripping char from left side of string"

    printf '%s\n' "${string:1}"
}


##
## Strip a char from the right side of a string
##

function string::rstrip {
    [[ "${#}" -le 1 ]] || return 2

    local string="${1:-}"

    if var::is_empty "${string}" && var::is_stdin
    then
        string="$( < /dev/stdin )"
    elif var::is_empty "${string}"
    then
        return 1
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Stripping char from right side of string"

    printf '%s\n' "${string::-1}"
}


##
## Strip a set of chars from the front of a string
##

function string::strip_prefix {
    [ "${#}" -ne 2 ] && return 2

    local -r string="${1}"
    local -r prefix="${2}"

    log::trace "${FUNCNAME[0]}: ${*} - Strip prefix ${prefix} from string ${string}"

    printf "%s" "${string##${prefix}}"
}


##
## Strip a set of chars from the back of a string
##

function string::strip_suffix {
    [ "${#}" -ne 2 ] && return 2

    local -r string="${1}"
    local -r suffix="${2}"

    log::trace "${FUNCNAME[0]}: ${*} - Strip suffix ${suffix} from string ${string}"

    printf "%s" "${string%${suffix}}"
}


##
## Check if a string contains a set of chars
##

function string::contains {
    [ "${#}" -ne 2 ] && return 2

    local -r needle="${1}"
    local -r haystack="${2}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if string contains substring"

    [[ "${haystack}" == *${needle}* ]]
}


##
## Check if string starts with a set of chars
##

function string::startswith {
    [ "${#}" -ne 2 ] && return 2

    local -r needle="${1}"
    local -r haystack="${2}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if string starts with pattern"

    [[ "${haystack}" == "${needle}"* ]]
}


##
## Check if a string ends with a set of chars
##

function string::endswith {
    [ "${#}" -ne 2 ] && return 2

    local -r needle="${1}"
    local -r haystack="${2}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if string ends with pattern"

    [[ "${haystack}" == *"${needle}" ]]
}


##
## Check if string is equal to a set of chars
##

function string::equals {
    [ "${#}" -ne 2 ] && return 2

    local -r first="${1}"
    local -r second="${2}"

    log::trace "${FUNCNAME[0]}: ${*} -  Checking if string equals pattern"

    [[ "${first}" == "${second}" ]]
}


##
## Check if string is not equal to a set of chars
##

function string::not {
    [ "${#}" -ne 2 ] && return 2

    local -r first="${1}"
    local -r second="${2}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if string equals pattern"

    [[ "${first}" != "${second}" ]]
}


##
## Print a box around a string
##

function string::box {
    local -r t="${1}xxxx"
    local -r c=${2:-#}

    log::trace "${FUNCNAME[0]}: ${*} - Printing a box around string"

    echo "${t//?/${c}}"
    echo "${c} ${1} ${c}"
    echo "${t//?/${c}}"
}

function box {
    string::box "${@}"
}
