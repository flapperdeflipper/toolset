#!/usr/bin/env bash

##
## Define import function
##

function core::import {
    local filename
    local filepath

    local -ra names=("${@}")

    ## Loop over all files given as input
    for file in "${names[@]}"
    do
        ## Check if lib with file extension found in PATH
        if ! filepath="$( which "${file}.sh" )"
        then
            ## Otherwise check if file without extension is a script
            if file "$( which "${file}" )" | grep -q 'shell script'
            then
                ## If so, set as filepath
                filepath="$( which "${file}" )"
            fi
        fi

        ## If filepath doesn't exist, it doesn't exist as file or file.sh in PATH
        if [[ ! -f "${filepath}" ]]
        then
            ## check if it's a full path that is given
            if [[ -f "${file}" ]]
            then
                ## If so, set the basename and assume it's in library path
                filename="$( basename "${file}" )"
            else
                ## if not, append file extension and assume it's in library path
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
