#!/usr/bin/env bats

load "../../../bin/toolset"

##
## fs::is_dir
##

@test "Test that fs::is_dir returns 0 if directory exists" {
    run fs::is_dir /tmp
    [ "${status}" -eq 0 ]
}

@test "Test that fs::is_dir returns 1 if directory does not exist" {
    run fs::is_dir /doesnotexist
    [ "${status}" -eq 1 ]
}


##
## fs::is_file
##

@test "Test that fs::is_file returns 0 if file exists" {
    run fs::is_file /etc/passwd
    [ "${status}" -eq 0 ]
}

@test "Test that fs::is_file returns 1 if file does not exist" {
    run fs::is_file /doesnotexist
    [ "${status}" -eq 1 ]
}


##
## fs::is_device
##

@test "Test that fs::is_device returns 0 if device exists" {
    run fs::is_device /dev/disk1
    [ "${status}" -eq 0 ]
}

@test "Test that fs::is_device returns 1 if device does not exist" {
    run fs::is_device /dev/doesnotexist
    [ "${status}" -eq 1 ]
}


##
## fs::is_socket
##

@test "Test that fs::is_socket returns 0 if socket exists" {
    local socket=$( find /tmp/ -type s | head -n 1 )
    run fs::is_socket "${socket}"
    [ "${status}" -eq 0 ]
}

@test "Test that fs::is_socket returns 1 if socket does not exist" {
    run fs::is_socket /dev/doesnotexist
    [ "${status}" -eq 1 ]
}


##
## fs::is_pipe
##

@test "Test that fs::is_pipe returns 0 if pipe exists" {
    [ -e /tmp/testpipe ] || mkfifo /tmp/testpipe

    run fs::is_pipe "/tmp/testpipe"
    [ "${status}" -eq 0 ]

    rm /tmp/testpipe
}

@test "Test that fs::is_pipe returns 1 if pipe does not exist" {
    run fs::is_pipe /dev/doesnotexist
    [ "${status}" -eq 1 ]
}


##
## fs::is_link
##

@test "Test that fs::is_link returns 0 if link exists" {
    run fs::is_link ~/bin
    [ "${status}" -eq 0 ]
}

@test "Test that fs::is_link returns 1 if link does not exist" {
    run fs::is_link /dev/doesnotexist
    [ "${status}" -eq 1 ]
}


##
## fs::is_executable
##

@test "Test that fs::is_executable returns 0 if executable exists" {
    run fs::is_executable /bin/bash
    [ "${status}" -eq 0 ]
}

@test "Test that fs::is_executable returns 1 if executable does not exist" {
    run fs::is_executable /doesnotexist
    [ "${status}" -eq 1 ]
}


##
## fs::exists
##

@test "Test that fs::exists returns 0 if file exists" {
    run fs::exists /bin/bash
    [ "${status}" -eq 0 ]
}

@test "Test that fs::exists returns 1 if file does not exist" {
    run fs::exists /doesnotexist
    [ "${status}" -eq 1 ]
}


##
## fs::is_regex
##

@test "Test that fs::is_regex returns 0 if file matches regex" {
    run fs::is_regex "/etc/passwd" "Unprivileged User" "--"
    [ "${status}" -eq 0 ]

    run fs::is_regex "/etc/passwd" "^root:" "-E"
    [ "${status}" -eq 0 ]

    run fs::is_regex "/etc/passwd" '\/\w+\/\w+\/false$' "-P"
    [ "${status}" -eq 0 ]

}

@test "Test that fs::is_regex returns 1 if file does not match regex" {
    run fs::is_regex "/etc/passwd" "UnprivilegedUser" "--"
    [ "${status}" -eq 1 ]

    run fs::is_regex "/etc/passwd" "root$" "-E"
    [ "${status}" -eq 1 ]

    run fs::is_regex "/etc/passwd" 'somethingnothing' "-P"
    [ "${status}" -eq 1 ]

    run fs::is_regex "doesnotexist" 'somethingnothing' "-P"
    [ "${status}" -eq 1 ]
}

##
## fs::regex_count
##

@test "Test that fs::regex_count returns the lines count" {
    [ "$( fs::regex_count "/etc/passwd" "Unprivileged User" )" == 1 ]
    [ "$( fs::regex_count "/etc/passwd" "root" )" == 3 ]

    run fs::regex_count "doesnotexist" "root"
    [ "${status}" -eq 1 ]
}

