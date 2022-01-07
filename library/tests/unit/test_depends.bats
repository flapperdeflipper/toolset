#!/usr/bin/env bats

load "../../../bin/toolset"


##
## depends::is_root
##

@test "Test that depends::is_root returns 1 if not run as root" {
    run depends::is_root
    [ "$status" -eq 1 ]
}


##
## depends::executable
##

@test "Test that depends::executable returns 0 if dependency exists" {
    run depends::executable find
    [ "$status" -eq 0 ]
}

@test "Test that depends::executable returns 0 if dependency does not exist" {
    run depends::executable doesnotexist
    [ "$status" -eq 1 ]
}


##
##  depends::check::silent
##

@test "Test that depends::check::silent returns 0 if dependency exists" {
    run depends::check::silent find
    [ "$status" -eq 0 ]
}

@test "Test that depends::check::silent returns 1 if dependency does not exist" {
    run depends::check::silent doesnotexist
    [ "$status" -eq 1 ]
}


##
## depends::check
##

@test "Test that depends::check returns 0 if dependency exists" {
    run depends::check find
    [ "$status" -eq 0 ]
}

@test "Test that depends::check returns 1 if dependency doest not exist" {
    run depends::check doesnotexist
    [ "$status" -eq 1 ]
}


##
## depends::check_list::silent
##

@test "Test that depends::check_list::silent returns 0 if all dependencies in list exist" {
    run depends::check_list::silent "find" "awk" "vim" "sed"
    [ "$status" -eq 0 ]
}

@test "Test that depends::check_list::silent returns 1 if all not dependencies in list exist" {
    run depends::check_list::silent "find" "awk" "vim" "sed" "doesnotexist"
    [ "$status" -eq 1 ]
}


##
## depends::check_list
##

@test "Test that depends::check_list returns 0 if all dependencies in list exist" {
    run depends::check_list "find" "awk" "vim" "sed"
    [ "$status" -eq 0 ]
}

@test "Test that depends::check_list returns 1 if not all dependencies in list exist" {
    run depends::check_list "find" "awk" "vim" "sed" "doesnotexist"
    [ "$status" -eq 1 ]
}
