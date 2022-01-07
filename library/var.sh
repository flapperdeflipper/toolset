#!/usr/bin/env bash

################################################################################
## VAR:: Stdin                                                                ##
################################################################################

function var::is_stdin {

    log::trace "${FUNCNAME[0]}: ${*} - Checking if a tty is alocated"

    if test ! -t 0
    then
        return 0
    fi

    return 1
}


################################################################################
## VAR:: Variable helpers                                                     ##
################################################################################

##
## Check if var is true
##

function var::is_true {
    [ ${#} -ne 1 ] && return 2

    local value="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if value is true"

    if [[ "${value}" == "true" ]] \
    || [[ "${value}" == 1 ]]
    then
        return 0
    fi

    return 1
}


##
## Check if var is false
##

function var::is_false {
    [ "${#}" -ne 1 ] && return 2

    local value="${1:-null}"

    log::error "${FUNCNAME[0]}: Checking if value is false"

    if [[ "${value}" == "false" ]] \
    || [[ "${value}" == 0 ]]
    then
        return 0
    fi

    return 1
}


##
## Check if var is either true or false
##

function var::is_bool {
    [ "${#}" -ne 1 ] && return 2

    local value="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if value is a boolean"

    if [[ "${value}" = true || "${value}" = false ]]
    then
        return 0
    fi

    return 1
}


##
## Check if var is null
##

function var::is_null {
    [ "${#}" -ne 1 ] && return 2

    local value="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if value is null"

    if [[ -z "${value}" || "${value}" = "null" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if var is defined
##

function var::defined {
    [ "${#}" -ne 1 ] && return 2

    local variable=${1}

    log::trace "${FUNCNAME[0]}: ${*} - Checking if variable is defined"

    if [[ "${!variable-X}" = "${!variable-Y}" ]]
    then
        return 0
    fi

    return 1
}


##
## Check if var is not empty
##

function var::has_value {
    [ "${#}" -ne 1 ] && return 2

    local value=${1}

    log::trace "${FUNCNAME[0]}: ${*} - Checking if value is not empty"
    if [[ -n "${value}" ]]
    then
        return 0
    fi

    return 1
}


##
## Check if var is empty
##

function var::is_empty {
    [ "${#}" -ne 1 ] && return 2

    local value=${1}

    log::trace "${FUNCNAME[0]}: ${*} - Checking if variable is empty"

    if [[ -z "${value}" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if var is equal to
##

function var::equals {
    [ "${#}" -ne 2 ] && return 2

    local value=${1}
    local equals=${2}

    log::trace "${FUNCNAME[0]}: ${*} - Checking if variable equals string"

    if [[ "${value}" = "${equals}" ]]
    then
        return 0
    fi

    return 1
}


##
## Check if var matches a given regex
##

function var::matches {
    [ "${#}" -ne 2 ] && return 2

    local input="${1}"
    local regex="${2}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if variable matches regex"

    if [[ "${input}" =~ $regex ]]
    then
        return 0
    fi

    return 1
}

##
## Check if var is numeric
##

function var::is_numeric {
    [ "${#}" -ne 1 ] && return 2

    local input="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if variable is numeric"

    var::matches "${input}" '^[0-9]+$'

    return "${?}"
}

##
## Check if var is alphanumeric
##

function var::is_alphanumeric {
    [ "${#}" -ne 1 ] && return 2

    local input="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if variable is alphanumeric"

    var::matches "${input}" '^[0-9a-zA-Z]+$'

    return "${?}"
}


##
## Check if var is alpha
##

function var::is_alpha {
    [ "${#}" -ne 1 ] && return 2

    local input="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if variable is alpha"

    var::matches "${input}" '^[a-zA-Z]+$'

    return "${?}"
}


##
## Check if var is an integer
##

function var::is_int {
    [ "${#}" -ne 1 ] && return 2

    local input="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if variable is an integer"

    var::matches "${input}" '^[+-]?[0-9]+$'

    return "${?}"
}


##
## Check if var is a flotation
##

function var::is_float {
    [ "${#}" -ne 1 ] && return 2

    local input="${1}"

    log::trace "${FUNCNAME[0]}: ${*} - Checking if variable is a floatation"

    var::matches "${input}" '^[+-]?[0-9]+\.[0-9]*$'

    return "${?}"
}

################################################################################
## Boolean comparison                                                         ##
################################################################################

##
## Check if all are truthy
##

function var::all {
    [ "${#}" -le 1 ] && return 2

    local -a input=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Checking if all vars are nonzero"

    for var in "${input[@]}"
    do
        if [[ -z "${var}" ]]
        then
            return 1
        fi
    done

    return 0
}


##
## Check if one of the two is set
##

function var::any {
    [ "${#}" -le 1 ] && return 2

    local -a input=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Check if any of the variables are nonzero"

    for var in "${input[@]}"
    do
        if [[ -n "${var}" ]]
        then
            return 0
        fi
    done

    return 1
}


##
## Check if none are set
##

function var::none {
    [ "${#}" -le 1 ] && return 2

    local -a input=("${@}")

    log::trace "${FUNCNAME[0]}: ${*} - Check of all of the variables are none"

    for var in "${input[@]}"
    do
        if [[ -n "${var}" ]]
        then
            return 1
        fi
    done

    return 0
}


################################################################################
## Integer comparison                                                         ##
################################################################################

##
## Check if var integer is lower than
##

function var::lt {
    [ "${#}" -ne 2 ] && return 2

    local var1="${1:-""}"
    local var2="${2:-""}"

    if ! var::is_int "${var1}" \
        || ! var::is_int "${var2}"
    then
        log::error "${FUNCNAME[0]}: Cannot compare non-integers in value"
        return 2
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Checking if var1 is lower than var2"

    if [[ "${var1}" -lt "${var2}" ]]
    then
        return 0
    fi

    return 1
}


##
## Check if var integer is lower or equal
##

function var::le {
    [ "${#}" -ne 2 ] && return 2

    local var1="${1:-""}"
    local var2="${2:-""}"

    if ! var::is_int "${var1}" \
        || ! var::is_int "${var2}"
    then
        log::error "${FUNCNAME[0]}: Cannot compare non-integers in value"
        return 2
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Checking if var1 is lower or equal than var2"

    if [[ "${var1}" -le "${var2}" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if var integer is greater than
##

function var::gt {
    [ "${#}" -ne 2 ] && return 2

    local var1="${1:-""}"
    local var2="${2:-""}"

    if ! var::is_int "${var1}" \
        || ! var::is_int "${var2}"
    then
        log::error "${FUNCNAME[0]}: Cannot compare non-integers in value"
        return 2
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Checking if var1 is greater than var2"


    if [[ "${var1}" -gt "${var2}" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if var integer is greater or equal
##

function var::ge {
    [ "${#}" -ne 2 ] && return 2

    local var1="${1:-""}"
    local var2="${2:-""}"

    if ! var::is_int "${var1}" \
        || ! var::is_int "${var2}"
    then
        log::error "${FUNCNAME[0]}: Cannot compare non-integers in value"
        return 2
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Checking if var1 is greater or equal to var2"

    if [[ "${var1}" -ge "${var2}" ]]
    then
        return 0
    fi

    return 1
}


##
## Check if var integer is equal
##

function var::eq {
    [ "${#}" -ne 2 ] && return 2

    local var1="${1:-""}"
    local var2="${2:-""}"

    if ! var::is_int "${var1}" \
        || ! var::is_int "${var2}"
    then
        log::error "${FUNCNAME[0]}: - Cannot compare non-integers in value"
        return 2
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Checking if var1 is equal to var2"

    if [[ "${var1}" -eq "${var2}" ]]
    then
        return 0
    fi

    return 1
}

##
## Check if var is integer not equal
##

function var::ne {
    [ "${#}" -ne 2 ] && return 2

    local var1="${1:-""}"
    local var2="${2:-""}"

    if ! var::is_int "${var1}" \
        || ! var::is_int "${var2}"
    then
        log::error "${FUNCNAME[0]}: Cannot compare non-integers in value"
        return 2
    fi

    log::trace "${FUNCNAME[0]}: ${*} - Checking if var1 is not equal to var2"

    if [[ "${var1}" -ne "${var2}" ]]
    then
        return 0
    fi

    return 1
}


##
## Add two vars
##

function var::sum {
    [ "${#}" -lt 2 ] && return 2

    local -a array=("${@}")
    local -i total=0

    log::trace "${FUNCNAME[0]}: ${*} - Adding all vars"

    for var in "${array[@]}"
    do
        if ! var::is_int "${var}"
        then
            log::error "${FUNCNAME[0]}: Cannot sum non-integers in value"
            return 2
        fi

        total=$(( total + var ))
    done

    printf '%d\n' "${total}"

    return "${?}"
}

##
## Increment var
##

function var::incr {
    { [ "${#}" -lt 1 ] || [ "${#}" -gt 2 ]; } && return 2

    local -i var="${1}"
    local -i amount="${2:-1}"

    [[ "${amount}" -ne 0 ]] || return 2

    log::trace "${FUNCNAME[0]}: ${*} - Incrementing var"

    if ! var::is_int "${var}" \
    || ! var::is_int "${amount}"
    then
        log::error "${FUNCNAME[0]}: - Cannot increment non-integers in value"
        return 2
    fi

    printf '%d\n' "$(( var + amount ))"

    return "${?}"
}

##
## Decrement var
##

function var::decr {
    { [ "${#}" -lt 1 ] || [ "${#}" -gt 2 ]; } && return 2

    local -i var="${1}"
    local -i amount="${2:-1}"

    [[ "${amount}" -ne 0 ]] || return 2

    log::trace "${FUNCNAME[0]}: ${*} - Decrementing var"

    if ! var::is_int "${var}" \
    || ! var::is_int "${amount}"
    then
        log::error "${FUNCNAME[0]}: Cannot decrement non-integers in value"
        return 2
    fi

    printf '%d\n' "$(( var - amount ))"

    return "${?}"
}

