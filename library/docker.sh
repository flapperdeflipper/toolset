#!/usr/bin/env bash

################################################################################
## docker-compose functions                                                   ##
################################################################################

function docker::compose_build {
    if ! fs::is_file docker-compose.yml
    then
       log::err "${FUNCNAME[0]}: Can't build when there isn't a docker-compose.yml file in the current dir"
       return 1
    fi

    log::info "** Starting docker compose build"

    docker compose up --build
}

function docker::compose_rebuild {
    local service="${1:-""}"

    if var::is_empty "${service}"
    then
        log::err "${FUNCNAME[0]}: Usage: compose-rebuild <service>"
        return 1
    fi

    log::info "** Rebuilding service ${service}"

    docker compose -d --no-deps --build "${service}"
}


#############################################
## Docker                                  ##
#############################################

function docker::connect {

    if ! docker ps &>/dev/null
    then
        log::err "${FUNCNAME[0]}: Docker daemon is not running! (ಠ_ಠ)"
        return 1
    fi

    local container

    container="$( \
        docker ps \
        | awk '{if (NR!=1) print $1 ": " $(NF)}' \
        | fzf --height 40% \
    )"

    if var::has_value "${container}"
    then
        local container_id
              container_id="$( \
                  echo "${container}" | awk -F ': ' '{print $1}' \
              )"

        docker exec -it "${container_id}" /bin/bash \
            || docker exec -it "${container_id}" /bin/sh
    else
        log::err "${FUNCNAME[0]}: You haven't selected any container! ༼つ◕_◕༽つ"
        return 1
    fi
}


function docker::clean_images {
    log::info "** Removing all docker images"

    docker images -a \
        | sed 1d \
        | awk '{print $3}' \
        | xargs docker rmi -f
}


function docker::clean_all {
    log::info "** Removing all exited docker containers"

    docker ps -a \
        | sed 1d \
        | grep Exited \
        | awk '{print $1}' \
        | xargs docker rm -f
}


function docker::kill_all {
    log::info "** Killing all running docker container"

    docker ps -a \
        | sed 1d \
        | awk '{print $1}' \
        | xargs docker kill
}


function docker::remove_all {
    log::info "Removing all running docker containers"

    docker ps -a \
        | sed 1d \
        | awk '{print $1}' \
        | xargs docker rm -f
}


function docker::prune {
    log::info "Purging as much as possible"

    docker stop "$( docker ps -a -q )"
    docker system prune -f -a
}


function docker::force_clean {
    log::info "** Cleaning up running containers"

    docker ps -a \
       | sed 1d \
       | awk '{ print $1 }' \
       | xargs docker rm -f

    log::info "** Cleaning up used images"

    docker images -a \
        | sed 1d \
        | awk '{ print $3 }' \
        | xargs docker rmi -f

    log::info "** Cleaning up used volumes"

    docker volume ls \
        | sed 1d \
        | awk '{ print $2 }' \
        | xargs docker volume rm -f

    log::info "** Cleaning up used networks"

    docker network ls \
        | sed 1d \
        | awk '{ print $1 }' \
        | xargs docker network rm 2>/dev/null
}


function docker::clean {
    log::info "** Removing unused images"

    docker images -a \
        | sed 1d \
        | grep '<none' \
        | awk '{print $3}' \
        | xargs docker rmi

    log::info "** Removing exited containers"

    docker ps -a \
        | sed 1d \
        | grep -vE ' Up ' \
        | grep Exited \
        | awk '{ print $1 }' \
        | xargs docker rm -f
}
