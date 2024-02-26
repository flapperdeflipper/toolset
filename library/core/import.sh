#!/usr/bin/env bash
# vi: ft=bash
# shellcheck shell=bash disable=SC1091,SC2154,SC2230,SC2312

##
## Check if a file can be sourced
##

function core::is_sourceable {
    [[ "${#}" -ne 1 ]] && return 2

    local file="${1}"; shift

    local filetype
          filetype="$(
            command file "${file}" \
              | awk -F ': ' '{ print $2 }' \
              | sed -e 's/\ \ /\ /g' \
              || true
          )"

    if [[ "${filetype}" =~ "toolset script" ]] \
    || [[ "${filetype}" =~ "sh script" ]] \
    || [[ "${filetype}" =~ "bash script" ]] \
    || [[ "${filetype}" =~ "^Bourne-Again shell" ]] \
    || [[ "${filetype}" =~ "^POSIX shell" ]] \
    || [[ "${filetype}" =~ "^ASCII text" ]]
    then
        return 0
    fi

    return 1
}


function core::import {
    [[ "${#}" -lt 1 ]] && return 2

    local source_file=""

    local -ra input=("${@}")

    ## Loop over all files given as input
    for file in "${input[@]}"
    do
        ## Check if file.sh in library_path
        if [[ -f "${TOOLSET_LIBRARY_PATH}/${file}.sh" ]]
        then
            source_file="${TOOLSET_LIBRARY_PATH}/${file}.sh"

        ## Check if file in library_path
        elif [[ -f "${TOOLSET_LIBRARY_PATH}/${file}" ]]
        then
            source_file="${TOOLSET_LIBRARY_PATH}/${file}"

        ##  Check if file is a full path to a file
        elif [[ -f "${file}" ]] \
        && core::is_sourceable "${file}"
        then
            source_file="${file}"

        ## Check if file.sh is in path
        elif which "${file}.sh" >/dev/null 2>&1
        then
            source_file="$( which "${file}.sh" )"

        ## Check if file is in path
        elif which "${file}" >/dev/null 2>&1
        then
            ## Check if file without extension is a script
            if core::is_sourceable "$( command -v "${file}" )"
            then
                ## If so, set as source_file
                source_file="$( which "${file}" )"
            fi
        fi

        if [[ ! -f "${source_file}" ]]
        then
            echo "ERROR: ${FUNCNAME[*]}: Import invalid: $( basename "${file}" )" > /dev/stderr
            continue
        fi

        # shellcheck source=/dev/null
        if ! source "${source_file}"
        then
            echo "ERROR: ${FUNCNAME[*]}: Failed to source ${source_file}..." > /dev/stderr
            continue
        fi
    done

    return 0
}


function import { core::import "${@}"; }
