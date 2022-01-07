#!/usr/bin/env bash

################################################################################
## Run bats test                                                              ##
################################################################################

function tests::runtests {
    (
        cd "${TOOLSET_LIBRARY_PATH}" || return 1

        if var::lt "${#}" 1
        then
            command bats --pretty -r tests/unit
        else
            for file in "${@}"
            do
                local file="tests/unit/${file}"
                fs::is_file "${file}" \
                    && bats --pretty "${file}"
            done
        fi
    )
}
