#!/usr/bin/env bats

load "../../../bin/toolset"


##
## array::contains
##

@test "Test that array::contains returns 0 when needle in haystack" {
    local -a array=(a b c d)

    run array::contains "a" "${array[@]}"
    [ "$status" -eq 0 ]
}

@test "Test that array::contains returns 1 when needle not in haystack" {
    local -a array=(a b c d)

    run array::contains "e" "${array[@]}"
    [ "$status" -eq 1 ]
}

@test "Test that array::contains returns 2 when invalid arguments" {
    run array::contains 1
    [ "$status" -eq 2 ]
}


##
## array::deduplicate
##

@test "Test that array::deduplicate dedups an array" {
    local -a array=(a a a b b b c c c)

    output=( $( array::deduplicate "${array[@]}" ) )

    [ "${output[0]}" == "a" ]
    [ "${output[1]}" == "b" ]
    [ "${output[2]}" == "c" ]
}

@test "Test that array::deduplicate returns 2 when invalid arguments" {
    local -a array=(a a a b b b c c c)

    run array::deduplicate
    [ "$status" -eq 2 ]

    run array::deduplicate "${array[@]}"
    [ "$status" -eq 0 ]
}



##
## array::lenght
##

@test "Test that array::length returns the length of an array" {
    local -a array=(a a a b b b c c c)

    output="$( array::length "${array[@]}" )"

    [ "${output}" -eq 9 ]
}

@test "Test that array::length returns 2 when invalid arguments" {
    local -a array=(a a a b b b c c c)

    run array::length
    [ "$status" -eq 2 ]

    run array::length "${array[@]}"
    [ "$status" -eq 0 ]
}

##
## array::is_empty
##

@test "Test that array::is_empty returns 0 if array is empty" {
    local -a array

    run array::is_empty "${array[@]}"
    [ "$status" -eq 0 ]
}

@test "Test that array::is_empty returns 1 if array is not empty" {
    local -a array
    array=(1 2 3 4)

    run array::is_empty "${array[@]}"
    [ "$status" -eq 1 ]
}

##
## array::join
##

@test "Test that array::join joins 2 arrays" {
    local -a array1=(1 2 3 4)

    output="$( array::join - "${array1[@]}" )"
    [ "$output" == "1-2-3-4" ]
}

@test "Test that array::join returns 2 when invalid arguments" {
    run array::join 1
    [ "$status" -eq 2 ]

    run array::join - a b c d
    [ "$status" -eq 0 ]
}

##
## array::reverse
##

@test "Test that array::reverse reverses an array" {
    local -a array1=(1 2 3 4)
    output=($( array::reverse "${array1[@]}" ))

    [ "${output[0]}" == "4" ]
    [ "${output[1]}" == "3" ]
    [ "${output[2]}" == "2" ]
    [ "${output[3]}" == "1" ]
}

@test "Test that array::reverse returns 2 when invalid arguments" {
    run array::reverse
    [ "$status" -eq 2 ]

    run array::reverse 1 2 3 4
    [ "$status" -eq 0 ]
}

##
## array::random_element
##

@test "Test that array::random_element returns 2 when invalid arguments" {
    run array::random_element
    [ "$status" -eq 2 ]
}

@test "Test that array::random_element returns 0 when valid arguments" {
    local -a array1=(1 2 3 4)

    run array::random_element "${array1[@]}"
    [ "$status" -eq 0 ]
}

##
## array::sort
##

@test "Test that array::sort sorts an array" {
    local -a array1=(a c b d)
    output=($( array::sort "${array1[@]}" ))

    [ "${output[0]}" == "a" ]
    [ "${output[1]}" == "b" ]
    [ "${output[2]}" == "c" ]
    [ "${output[3]}" == "d" ]
}

@test "Test that array::sort returns 2 when invalid arguments" {
    run array::sort
    [ "$status" -eq 2 ]

    run array::sort a b c d
    [ "$status" -eq 0 ]
}

##
## array::sort-r
##

@test "Test that array::sort-r reverse sorts an array" {
    local -a array1=(a c b d)
    output=($( array::sort-r "${array1[@]}" ))

    [ "${output[0]}" == "d" ]
    [ "${output[1]}" == "c" ]
    [ "${output[2]}" == "b" ]
    [ "${output[3]}" == "a" ]
}

@test "Test that array::sort-r returns 2 when invalid arguments" {
    run array::sort-r
    [ "$status" -eq 2 ]

    run array::sort-r a b c d
    [ "$status" -eq 0 ]
}

##
## array::pop_by_name
##

@test "Test that array::pop_by_name removes a named element from an array" {
    local -a array1=(a b c d)
    output=($( array::pop_by_name a "${array1[@]}" ))

    [ "${output[0]}" == "b" ]
    [ "${output[1]}" == "c" ]
    [ "${output[2]}" == "d" ]

    local -a array1=(a b c d)
    output=($( array::pop_by_name e "${array1[@]}" ))

    [ "${output[0]}" == "a" ]
    [ "${output[1]}" == "b" ]
    [ "${output[2]}" == "c" ]
    [ "${output[3]}" == "d" ]


    local -a array1=(a b c d a b c d)
    output=($( array::pop_by_name a "${array1[@]}" ))

    [ "${output[0]}" == "b" ]
    [ "${output[1]}" == "c" ]
    [ "${output[2]}" == "d" ]
    [ "${output[3]}" == "b" ]
    [ "${output[4]}" == "c" ]
    [ "${output[5]}" == "d" ]
}


@test "Test that array::pop_by_name returns 2 when invalid arguments" {
    run array::pop_by_name 1
    [ "$status" -eq 2 ]

    run array::pop_by_name a a b c d
    [ "$status" -eq 0 ]
}


##
## array::pop_by_position
##

@test "Test that array::pop_by_position removes a named element from an array" {
    local -a array1=(a b c d)

    output=($( array::pop_by_position 1 "${array1[@]}" ))

    [ "${output[0]}" == "a" ]
    [ "${output[1]}" == "c" ]
    [ "${output[2]}" == "d" ]

    output=($( array::pop_by_position 2 "${array1[@]}" ))

    [ "${output[0]}" == "a" ]
    [ "${output[1]}" == "b" ]
    [ "${output[2]}" == "d" ]

    output=($( array::pop_by_position 3 "${array1[@]}" ))

    [ "${output[0]}" == "a" ]
    [ "${output[1]}" == "b" ]
    [ "${output[2]}" == "c" ]

    output=($( array::pop_by_position 5 "${array1[@]}" ))

    [ "${output[0]}" == "a" ]
    [ "${output[1]}" == "b" ]
    [ "${output[2]}" == "c" ]
    [ "${output[3]}" == "d" ]
}


@test "Test that array::pop_by_position returns 2 when invalid arguments" {
    run array::pop_by_position 1
    [ "$status" -eq 2 ]
}

@test "Test that array::pop_by_position returns 2 when non numeric pos" {
    local -a array1=(a b c d a b c d)
    run array::pop_by_position a "${array[@]}"
    [ "$status" -eq 2 ]
}


##
## array::first
##

@test "Test that array::first prints the first element of an array" {
    local -a array1=(a b c d)

    output="$( array::first "${array1[@]}" )"
    [ "${output}" == "a" ]
}

@test "Test that array::first returns 2 when invalid arguments" {
    run array::first
    [ "$status" -eq 2 ]

    run array::first a b c d
    [ "$status" -eq 0 ]
}

##
## array::last
##

@test "Test that array::last prints the last element of an array" {
    local -a array1=(a b c d)

    output="$( array::last "${array1[@]}" )"
    [ "${output}" == "d" ]
}

@test "Test that array::last returns 2 when invalid arguments" {
    run array::last
    [ "$status" -eq 2 ]

    run array::last a b c d
    [ "$status" -eq 0 ]
}

##
## array::get
##

@test "Test that array::get prints the Nth element of an array" {
    local -a array1=(a b c d)

    output="$( array::get 0 "${array1[@]}" )"
    [ "${output}" == "a" ]

    output="$( array::get 1 "${array1[@]}" )"
    [ "${output}" == "b" ]

    output="$( array::get 2 "${array1[@]}" )"
    [ "${output}" == "c" ]

    output="$( array::get 3 "${array1[@]}" )"
    [ "${output}" == "d" ]
}

@test "Test that array::get returns 2 when invalid arguments" {
    run array::get
    [ "$status" -eq 2 ]

    run array::get 1 a b c d
    [ "$status" -eq 0 ]
}

@test "Test that array::get returns 2 when non numeric pos" {
    local -a array1=(a b c d a b c d)

    run array::get a "${array[@]}"
    [ "$status" -eq 2 ]
}

