#!/usr/bin/env bash

##
## Initialize cache
##

function cache::init {
    local dir="${1:-}"; shift || true

    ## export the cache directory
    export cachedir="${dir:-"${HOME}/.local/cache/bash"}"

    log::trace "${FUNCNAME[0]}: Initializing cache in ${cachedir}"

    ## set to volatile if --volatile is passed
    if string::contains "--volatile" "${*}" \
    || string::contains "-v" "${*}"
    then
        ## Set the cache extension to the pid of the script
        export cache_extension="${$}"

        ## Clear out cache on exit, sigint and sigquit
        trap cache::flushall SIGINT SIGQUIT EXIT
    else
        export cache_extension="cache"
    fi

    ## Create cachedir
    if ! fs::is_dir "${cachedir}"
    then
        if ! mkdir -p "${cachedir}"
        then
            log::error "${FUNCNAME[0]}: Failed to create ${cachedir}"
            return 1
        else
            cache::set "initialized" "$( date )" || return 1
        fi
    fi

    return 0
}


##
## Check of cache is initialized
##
function cache::is_initialized() {
    log::trace "${FUNCNAME[0]}: Checking if cache key is initialized"

    if var::is_null "${cache_dir:-}" \
    || var::is_null "${cache_extension:-}"
    then
        return 1
    fi

    return 0
}


##
## Print a warning if cache is not initialized
##
function cache::warning() {
    log::trace "${FUNCNAME[0]}: Checking if cache key is initialized"

    if ! cache::is_initialized \
    || ! cache::exists
    then
        log::warning "Cache is not initialized or missing!"
    fi
}

##
## Check if cache item exists
##

function cache::exists {
    local key="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if cache key ${key} exists"

    cache::warning || return 1

    if fs::is_file "${cachedir}/${key}.${cache_extension}"
    then
        return 0
    fi

    return 1
}


##
## Get key from cache
##

function cache::get {
    local key="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Retrieving key from cache"

    if ! cache::exists "${key}"
    then
        return 1
    fi

    if ! printf "%s" "$( < "${cachedir}/${key}.${cache_extension}" )"
    then
        log::warning "${FUNCNAME[0]}: Failed to retrieve ${key} from cache"
        return 1
    fi

    return 0
}


##
## Set key in cache
##

function cache::set {
    local key="${1}"
    local value="${2}"

    log::trace "${FUNCNAME[0]}: ${*} - Setting ${key}:${value} in cache"
    cache::warning || return 1

    if ! printf "%s" "$value" > "${cachedir}/${key}.${cache_extension}"
    then
        log::warning "${FUNCNAME[0]}: Failed to set ${key} in cache"
        return 1
    fi

    return 0
}


##
## Remove key from cache
##

function cache::flush {
    local key=${1}

    log::trace "${FUNCNAME[0]}: ${*} - Flushing ${key} from cache"
    cache::warning || return 1

    if ! rm -f "${cachedir}/${key}.${cache_extension}"
    then
        ::exit.nok "An error while flushing ${key} from cache"
        return 1
    fi

    return 0
}

##
## Clear out the cache
##

function cache::flushall {
    log::trace "${FUNCNAME[0]}: ${*} - Flushing all keys from cache"
    cache::warning || return 1

    if ! fs::is_dir "${cachedir}"
    then
         return 0
    fi

    if ! rm -rf "${cachedir}"
    then
        log::error "${FUNCNAME[0]}: Could not flush cache"
        return 1
    fi

    return 0
}

