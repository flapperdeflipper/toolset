#!/usr/bin/env bash
# shellcheck disable=SC2312

##
## Check if array contains element
##

function array::contains {
    [[ $# -lt 2 ]] \
        && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2

    local needle="${1}"
    local haystack=("${2}")

    log::trace "${FUNCNAME[0]}: ${*} - Checking if array contains ${needle}"

    for element in "${haystack[@]}"
    do
        if var::equals "${element}" "${needle}"
        then
            return 0
        fi
    done

    return 1
}


##
## Remove duplicate fields from an array
##

function array::deduplicate {
    [[ "${#}" -lt 1 ]] \
        && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2

    local -A arr_tmp
    local -a arr_unique

    log::trace "${FUNCNAME[0]}: ${*} - Deduplicating array"

    for i in "${@}"
    do
        { [[ -z ${i:-} ]] || [[ -n "${arr_tmp[${i}]}" ]]; } && continue

        arr_unique+=("${i}") && arr_tmp[${i}]=x
    done

    printf '%s\n' "${arr_unique[@]}"
}


##
## Get the length of an array
##

function array::length {
    [[ $# -lt 1 ]] \
        && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2

    local -a array
    local array=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving length of array"

    printf "%s" "${#array[@]}"
}


##
## Check if array is empty
##

function array::is_empty {
    local -a array

    log::trace "${FUNCNAME[0]}: ${*} - Checking if array is empty"

    local array=("${@}")

    if [[ ${#array[@]} -eq 0 ]]
    then
        return 0
    else
        return 1
    fi
}


##
## Check if an array is not empty
##

function array::not_empty {
    [[ $# -lt 1 ]] \
        && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2

    local -a array

    log::trace "${FUNCNAME[0]}: ${*} - Checking if array is not empty"

    local array=("${@}")

    if [[ ${#array[@]} -eq 0 ]]
    then
        return 1
    else
        return 0
    fi
}


##
## Join all fields in an array with a separator string or char
##

function array::join {
    [[ $# -lt 2 ]] \
        && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2

    local delimiter="${1}"
    shift

    log::trace "${FUNCNAME[0]}: ${*} - Joining array with delimiter ${delimiter}"

    printf "%s" "${1}"
    shift

    printf "%s" "${@/#/${delimiter}}"
}


##
## Reverse the order of an array
##

function array::reverse {
    [[ "${#}" -eq 0 ]] \
        && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2

    local min=0
    local -a array
    array=("${@}")
    local max=$((${#array[@]} - 1))

    log::trace "${FUNCNAME[0]}: ${*} - Reversing array"

    while [[ "${min}" -lt "${max}" ]]; do
        # Swap current first and last elements
        x="${array[${min}]}"

        array[min]="${array[${max}]}"
        array[max]="${x}"

        # Move closer
        ((min++, max--))
    done

    printf '%s\n' "${array[@]}"
}


##
## Retrieve a random element from an array
##

function array::random_element {
    [[ $# -lt 1 ]] && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2

    local -a array
    local array=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Printing random element from array"

    printf '%s\n' "${array[RANDOM % $#]}"
}

##
## Sort a numeric array
##

function array::sort {
    [[ $# -lt 1 ]] \
        && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2

    local -a array=("${@}")
    local -a sorted
    local noglobtate

    log::trace "${FUNCNAME[0]}: ${*} - Sorting array"

    noglobtate="$(shopt -po noglob)"

    set -o noglob

    local IFS=$'\n'

    mapfile -t sorted < <( sort <<< "${array[*]}" )

    unset IFS

    eval "${noglobtate}"

    printf "%s\n" "${sorted[@]}"
}

##
## Reverse sort a numeric array
##

function array::sort-r {
    [[ $# -lt 1 ]] \
        && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2

    local -a array=("${@}")
    local -a sorted
    local noglobstate

    log::trace "${FUNCNAME[0]}: ${*} - Sorting array reversed"

    noglobstate="$( shopt -po noglob )"

    set -o noglob

    local IFS=$'\n'

    mapfile -t sorted < <( sort -r <<< "${array[*]}" )

    unset IFS

    eval "${noglobstate}"

    printf "%s\n" "${sorted[@]}"
}


##
## Remove an element from an array by name
##

function array::pop_by_name {
    [[ $# -lt 2 ]] \
        && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2

    local name="${1:-}" ; shift
    local -a array=("${@}")
    local -a output
    local noglobstate

    log::trace "${FUNCNAME[0]}: ${*} - Popping element ${name} from array"

    noglobstate="$( shopt -po noglob )"

    set -o noglob

    local IFS=$'\n'

    for item in "${array[@]}"
    do
        if [[ "${item}" != "${name}" ]]
        then
            output+=("${item}")
        fi
    done

    unset IFS

    eval "${noglobstate}"

    printf "%s\n" "${output[@]}"
}


##
## Remove an element from an array by position
##

function array::pop_by_position {
    [[ $# -lt 2 ]] \
        && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2

    local -i pos="${1}" ; shift
    local -a array=("${@}")
    local -a output

    log::trace "${FUNCNAME[0]}: ${*} - Popping element ${pos} from array"

    unset "array[${pos}]"

    printf "%s\n" "${array[@]}"
}



##
## Get the first element of an array
##

function array::first {
    [[ $# -lt 1 ]] \
        && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2
    local -a array=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Printing first element from array"

    printf "%s\n" "${array[0]}"
}

##
## Get the last element of an array
##

function array::last {
    [[ $# -lt 1 ]] \
        &&  log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2
    local -a array=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Printing last element from array"

    printf "%s\n" "${array[-1]}"

}

##
## Get the Nth element of an array
##

function array::get {
    [[ $# -lt 2 ]] \
        && log::warning "%s: Missing arguments" "${FUNCNAME[0]}" && return 2

    local -i pos="${1}" ; shift
    local -a array=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Printing ${pos}th element from array"

    local -a array=("${@}")

    printf "%s\n" "${array[${pos}]}"
}
