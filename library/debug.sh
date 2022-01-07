#!/usr/bin/env bash

export TRACE=""
export SILENT=0


function debug::set_debug {
    export TRACE=1
}

function debug::unset_debug {
    export TRACE=""
}

function debug::set_silent {
    export SILENT=1
}

function debug::unset_silent {
    export SILENT=0
}
