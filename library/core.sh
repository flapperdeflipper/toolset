#!/usr/bin/env bash

##
## Define import function
##

function core::import {
    local filename
    local filepath

    local -ra names=("${@}")

    ## Loop over array
    for file in "${names[@]}"
    do
        if ! filepath="$( which "${file}.sh" )"
        then
            if file "$( which "${file}" )" | grep -q 'shell script'
            then
                filepath="$( which "${file}" )"
            fi
        fi

        if [[ ! -f "${filepath}" ]]
        then
            if [[ -f "${file}" ]]
            then
                filename="$( basename "${file}" )"
            else
                filename="${file}.sh"
            fi

            filepath="${TOOLSET_LIBRARY_PATH}/${filename}"
        fi

        if [[ ! -f "${filepath}" ]]
        then
            echo "ERROR: ${FUNCNAME[*]}: Import failed: ${filename} not found!" > /dev/stderr
            continue
        fi

        # shellcheck source=/dev/null
        if ! source "${filepath}"
        then
            echo "ERROR: ${FUNCNAME[*]}: Failed to source ${filepath}..." > /dev/stderr
            continue
        fi
    done

    return 0
}


function import { core::import "${@}"; }
