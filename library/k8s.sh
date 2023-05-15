#!/usr/bin/env bash

################################################################################
## kubernetes functions                                                       ##
################################################################################

##
## Form the name of a pod to a valid format
##

function k8s::podname {
    local -r podname="${1:-}"

    log::trace "${FUNCNAME[0]}: ${*} - Generating pod name for ${podname}"

    echo -n "$( \
        printf "%s-%s-%s" \
          "${podname}" \
          "$( tr -dc '0-9'    < /dev/urandom | fold -w10 | head -n1 )" \
          "$( tr -dc 'a-z0-9' < /dev/urandom | fold -w5  | head -n1 )" \
    )"
}


##
## Get multiple pods on the same node
##

function k8s::doublepod {
    command kubectl get pods --all-namespaces -o wide \
        | awk '{print $8 " " $2}'   \
        | sed -e 's/-.....$//g'     \
        | sort \
        | uniq -c \
        | sort -n \
        | grep -vE '^\ +1 '
}


##
## List all images in cluster
##

function k8s::images {

    command kubectl get pods --all-namespaces \
        -o jsonpath='{range .items[*]}{..image}{"\n"}{end}' \
      | sort \
      | uniq -c \
      | sort -n
}


##
## List all nodes in cluster
##

function k8s::nodes {

    if ! command kubectl get nodes \
       -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
    then
        log::error "${FUNCNAME[0]}: Failed to retrieve nodes for cluster"
        return 1
    fi

    return 0
}


##
## List all namespaces in cluster
##

function k8s::namespaces {

    if ! command kubectl get namespaces \
       -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'
    then
        log::error "${FUNCNAME[0]}: Failed to retrieve namespaces for cluster"
        return 1
    fi

    return 0
}


##
## Grep for pods
##

function k8s::grep {

    local wide=0
    local arguments=""
    local object="pods"
    local regex="."

    local watch=0
    local refresh=1

    ## Parse command line arguments
    while [ "${1:-}" != "" ]
    do
        case "${1}" in
            -w|--wide)
                wide=1
                shift
            ;;
            -i|--object)
                object="${2}"
                shift
            ;;
            -r|--regex)
                regex="${2}"
                shift
            ;;
            --watch)
                watch=1
            ;;
            --refresh)
                refresh="${2}"
                shift
            ;;
            *)
                arguments="${arguments} ${1:-} ${2:-}"
                shift
                ;;
        esac

        shift || true
    done

    var::is_empty "${arguments}" && arguments=" --all-namespaces"
    var::equals "${wide}" "1"    && arguments="${arguments} -o wide"

    local cmd="kubectl get ${object} ${arguments}"

    if var::eq "${watch}" 1
    then
        watch -n "${refresh}" "${cmd} | grep -E -- ${regex}"
    else
        ${cmd} | grep -E -- "${regex}"
    fi
}

##
## Check if object is valid
##

function k8s::is_valid_object {

    local -r search=${1:-}

    var::is_empty "${search}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Checking if ${1} is a valid k8s object"

    local objects

    objects="$( command kubectl api-resources --verbs=list -o name 2>&1 )"

    for object in ${objects}
    do
        if var::equals "${object}" "${search}" \
        || var::equals "${object}" "${search}s"
        then
            return 0
        fi
    done

    return 1
}


##
## Check if object exists
##

function k8s::object_exists {

    local -r name="${1:-}"
    local -r object="${2:-pod}"
    local -r namespace="${3:-default}"

    var::is_empty "${name}"   && return 1
    var::is_empty "${object}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::object_exists"

    local found=""

    if ! found="$( command kubectl -n "${namespace}" get "${object}" "${name}" --ignore-not-found )"
    then
        log::error "${FUNCNAME[0]}: Failed to retrieve object ${object}"
        return 1
    fi

    if var::has_value "${found}"
    then
        return 0
    fi

    return 1
}


##
## Delete an object
##

function k8s::delete_object {

    local -r name="${1:-}"
    local -r object="${2:-pod}"
    local -r namespace="${3:-default}"
    local -ir maxcount="${4:-10}"

    var::is_empty "${name}"   && return 1
    var::is_empty "${object}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::delete_object"

    if ! k8s::object_exists "${name}" "${object}" "${namespace}"
    then
        log::warning "${FUNCNAME[0]}: ${object} ${name} does not exists"
        return 0
    fi

    local -i count=0

    while k8s::object_exists "${name}" "${object}" "${namespace}" \
        && ! var::ge "${count}" "${maxcount}"
    do
        if ! chronic command kubectl delete \
            -n "${namespace}" "${object}" "${name}" --now
        then
            log::error "${FUNCNAME[0]}: Failed to delete ${object} ${name}"
            return 1
        fi

        ((count++))

        sleep 1
    done

    if var::ge "${count}" "${maxcount}"
    then
        return 1
    fi

    return 0
}


function k8s::podstate {
    local -r name="${1:-}"
    local -r namespace="${2:-default}"

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::podstate"

    if ! k8s::is_pod "${name}" "${namespace}"
    then
        log::error "${FUNCNAME[0]}: Pod ${name} does not exist"
        return 1
    fi

    if ! command kubectl get pod "${name}" \
           -n "${namespace}" \
           -o json \
           | jq -Mr .status.phase
    then
        log::error "${FUNCNAME[0]}: Failed to retrieve state for ${name} in ${namespace}"
        return 1
    fi

    return 0
}


function k8s::pod_is_ready {

    local -r name="${1:-}"
    local -r namespace="${2:-default}"
    local podstate

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::pod_is_ready"

    if ! k8s::is_pod "${name}" "${namespace}"
    then
        log::error "${FUNCNAME[0]}: Pod ${name} does not exist"
        return 1
    fi

    if ! podstate="$( k8s::podstate "${name}" "${namespace}" )"
    then
        log::error "${FUNCNAME[0]}: Failed to retrieve state for ${name}"
        return 1
    fi

    if var::equals "${podstate}" "Running"
    then
        return 0
    fi

    return 1
}


function k8s::pod_wait_until_ready {

    local -r name="${1:-}"
    local -r namespace="${2:-default}"
    local -ir maxcount="${4:-20}"

    var::is_empty "${name}"      && return 1
    var::is_empty "${namespace}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::pod_wait_until_ready"

    if ! k8s::is_pod "${name}" "${namespace}"
    then
        log::error "${FUNCNAME[0]}: Pod ${name} does not exist"
        return 1
    fi

    local -i count=1

    while ! k8s::pod_is_ready "${name}" "${namespace}" \
       && ! var::ge "${count}" "${maxcount}"
    do
        log::info "Waiting for pod ${name} to become ready... ${count}/${maxcount}"

        sleep 2

        ((count++))

    done

    if var::ge "${count}" "${maxcount}"
    then
        return 1
    fi

    return 0
}

##
## Drain a node
##

function k8s::drain {
    local node="${1:-}"

    var::is_empty "${node}" && return 1

    if ! k8s::is_node "${node}"
    then
        log::error "${FUNCNAME[0]}: Node ${node} not found!"
        return 1
    fi

    log::info "Draining node ${node}"

    if proc::log_action "kubectl drain ${node} --delete-local-data --ignore-daemonsets --force"
    then
        return 0
    fi

    return 1
}


##
## Cordon a node
##

function k8s::cordon {
    local node="${1:-}"

    var::is_empty "${node}" && return 1

    if ! k8s::is_node "${node}"
    then
        log::error "${FUNCNAME[0]}: Node ${node} not found!"
        return 1
    fi

    log::info "Cordoning node ${node}"

    if proc::log_action "kubectl cordon ${node}"
    then
        return 0
    fi

    return 1
}


##
## Check for existing object functions
##

function k8s::is_service {
    local -r name="${1:-}"
    local -r namespace="${2:-default}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_service"

    k8s::object_exists "${name}" svc "${namespace}"
}


function k8s::is_pod {
    local -r name="${1:-}"
    local -r namespace="${2:-default}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_pod"

    k8s::object_exists "${name}" pods "${namespace}"
}


function k8s::is_deployment {
    local -r name="${1:-}"
    local -r namespace="${2:-default}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_deployment"

    k8s::object_exists "${name}" deployment "${namespace}"
}


function k8s::is_statefulset {
    local -r name="${1:-}"
    local -r namespace="${2:-default}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_statefulset"

    k8s::object_exists "${name}" statefulset "${namespace}"
}


function k8s::is_configmap {
    local -r name="${1:-}"
    local -r namespace="${2:-default}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_configmap"

    k8s::object_exists "${name}" configmap "${namespace}"
}


function k8s::is_secret {
    local -r name="${1:-}"
    local -r namespace="${2:-default}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_secret"

    k8s::object_exists "${name}" secret "${namespace}"
}


function k8s::is_serviceaccount {
    local -r name="${1:-}"
    local -r namespace="${2:-default}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_serviceaccount"

    k8s::object_exists "${name}" serviceaccount "${namespace}"
}


function k8s::is_role {
    local -r name="${1:-}"
    local -r namespace="${2:-default}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_role"

    k8s::object_exists "${name}" role "${namespace}"
}


function k8s::is_rolebinding {
    local -r name="${1:-}"
    local -r namespace="${2:-default}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_rolebinding"

    k8s::object_exists "${name}" rolebinding "${namespace}"
}


function k8s::is_namespace {
    local -r name="${1:-}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_namespace"

    k8s::object_exists "${name}" namespace "none"
}


function k8s::is_node {
    local -r name="${1:-}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_node"

    k8s::object_exists "${name}" node "none"
}

function k8s::is_clusterrole {
    local -r name="${1:-}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_clusterrole"

    k8s::object_exists "${name}" clusterrole "none"
}


function k8s::is_clusterrolebinding {
    local -r name="${1:-}"

    var::is_empty "${name}" && return 1

    log::trace "${FUNCNAME[0]}: ${*} - Running k8s::is_clusterrolebinding"

    k8s::object_exists "${name}" clusterrolebinding "none"
}
