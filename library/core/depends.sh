#!/usr/bin/env bash

##
## Check if user is root
##

function depends::is_root {
    log::trace "${FUNCNAME[0]}: ${*} - Checking if current user is superuser"

    if [ "$( whoami )" == "root" ]
    then
        return 0
    fi

    return 1
}

##
## Check if dependency is found in PATH
##

function depends::in_path {
   local command="${1}"

   if fs::exists "$( which "${command}" )"
   then
       return 0
   fi

   return 1
}


##
## Check if dependency is executable
##

function depends::executable {
   local command="${1}"

   log::trace "${FUNCNAME[0]}: ${*} - Checking if dependency ${command} is executable"

   if fs::is_executable "$( which "${command}" )"
   then
       return 0
    fi

   return 1
}


##
## Silently check if dependency exists
##

function depends::check::silent {
    local command="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if dependency ${command} exists"

    if depends::executable "${command}"
    then
        return 0
    fi

    return 1
}


##
## Check if dependency exists (and log it)
##

function depends::check {
    local command="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking for required ${command}"

    if ! depends::executable "${command}"
    then
        log::error "${FUNCNAME[0]}: Missing requirement: ${command}"
        return 1
    fi

    return 0
}


##
## Check silently if a list of dependencies exist
##

function depends::check_list::silent {
    local requirements=("${@}")

    for dependency in "${requirements[@]}"
    do
        if ! depends::executable "${dependency}"
        then
            return 1
        fi
    done

    return 0
}


##
## Check if a list of dependencies exist (and log it)
##

function depends::check_list {
    local requirements=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} -Checking for list of dependencies"

    missing=0
    missing_names=""
    for dependency in "${requirements[@]}"
    do
        log::trace "${FUNCNAME[0]}: ${*} - Checking for dependency ${dependency}"

        if ! depends::executable "${dependency}"
        then
            missing=$((missing+1))
            missing_names="${missing_names} ${dependency}"
        fi
    done

    if [[ "${missing}" -ne 0 ]]
    then
        log::error "${FUNCNAME[0]}: Not all dependencies are found!"
        log::error "${FUNCNAME[0]}: Missing utils: ${missing_names}"
        return 1
    else
        return 0
    fi
}

