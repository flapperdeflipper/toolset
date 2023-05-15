#!/usr/bin/env bats

load "../../../bin/toolset"


##
## var::is_true
##

@test "Test that var::is_true returns 0 when var is true" {
    run var::is_true "true"
    [ "${status}" -eq 0 ]

    run var::is_true "1"
    [ "${status}" -eq 0 ]
}

@test "Test that var::is_true returns 1 when var is not true" {
    run var::is_true "some"
    [ "${status}" -eq 1 ]

    run var::is_true "0"
    [ "${status}" -eq 1 ]
}

@test "Test that var::is_true returns 2 on invalid input" {
    run var::is_true
    [ "${status}" -eq 2 ]

    run var::is_true "a" "b" "c"
    [ "${status}" -eq 2 ]
}


##
## var::is_false
##

@test "Test that var::is_false returns 0 when var is false" {
    run var::is_false "false"
    [ "${status}" -eq 0 ]

    run var::is_false "0"
    [ "${status}" -eq 0 ]
}

@test "Test that var::is_false returns 1 when var is not false" {
    run var::is_false "some"
    [ "${status}" -eq 1 ]

    run var::is_false "1"
    [ "${status}" -eq 1 ]
}

@test "Test that var::is_false returns 2 when invalid input" {
    run var::is_false
    [ "${status}" -eq 2 ]

    run var::is_false "a" "b" "c"
    [ "${status}" -eq 2 ]
}


##
## var::is_bool
##

@test "Test that var::is_bool returns 0 when var is bool" {
    run var::is_bool "true"
    [ "${status}" -eq 0 ]
}

@test "Test that var::is_bool returns 1 when var is not bool" {
    run var::is_bool "a"
    [ "${status}" -eq 1 ]
}

@test "Test that var::is_bool returns 2 when invalid input" {
    run var::is_bool "a" "a"
    [ "${status}" -eq 2 ]

    run var::is_bool
    [ "${status}" -eq 2 ]
}

##
## var::is_null
##

@test "Test that var::is_null returns 0 when var is null" {
    run var::is_null "null"
    [ "${status}" -eq 0 ]

    run var::is_null ""
    [ "${status}" -eq 0 ]
}

@test "Test that var::is_null returns 1 when var is not null" {
    run var::is_null "a"
    [ "${status}" -eq 1 ]
    run var::is_null "one"
    [ "${status}" -eq 1 ]
}

@test "Test that var::is_null returns 2 when invalid input" {
    run var::is_null
    [ "${status}" -eq 2 ]

    run var::is_null "a" "b" "c"
    [ "${status}" -eq 2 ]
}

##
## var::is_not_null
##

@test "Test that var::is_not_null returns 1 when var is null" {
    run var::is_not_null "null"
    [ "${status}" -eq 1 ]
    run var::is_not_null ""
    [ "${status}" -eq 1 ]
}

@test "Test that var::is_not_null returns 0 when var is not null" {
    run var::is_not_null "a"
    [ "${status}" -eq 0 ]

    run var::is_not_null "one"
    [ "${status}" -eq 0 ]
}

@test "Test that var::is_not_null returns 2 when invalid input" {
    run var::is_not_null
    [ "${status}" -eq 2 ]

    run var::is_not_null "a" "b" "c"
    [ "${status}" -eq 2 ]
}


##
## var::defined
##

@test "Test that var::defined returns 0 when var is defined" {
    variable="some"
    run var::defined "variable"
    [ "${status}" -eq 0 ]
}

@test "Test that var::defined returns 1 when var is not defined" {
    run var::defined "some"
    [ "${status}" -eq 1 ]
}

@test "Test that var::defined returns 2 when invalid input" {
    run var::defined "a" "b" "c"
    [ "${status}" -eq 2 ]

    run var::defined
    [ "${status}" -eq 2 ]
}


##
## var::has_value
##

@test "Test that var::has_value returns 0 when var has value" {
    run var::has_value "a"
    [ "${status}" -eq 0 ]
}

@test "Test that var::has_value returns 1 when var has no value" {
    run var::has_value ""
    [ "${status}" -eq 1 ]
}

@test "Test that var::has_value returns 2 when invalid input" {
    run var::has_value
    [ "${status}" -eq 2 ]

    run var::has_value "a" "b" "c"
    [ "${status}" -eq 2 ]
}


##
## var::is_empty
##

@test "Test that var::is_empty returns 0 when var is empty" {
    run var::is_empty ""
    [ "${status}" -eq 0 ]
}

@test "Test that var::is_empty returns 1 when var is not empty" {
    run var::is_empty "a"
    [ "${status}" -eq 1 ]
}

@test "Test that var::is_empty returns 2 when invalid input" {
    run var::is_empty "a" "b" "c"
    [ "${status}" -eq 2 ]

    run var::is_empty
    [ "${status}" -eq 2 ]
}


##
## var::equals
##

@test "Test that var::equals returns 0 when var matches input" {
    run var::equals "a" "a"
    [ "${status}" -eq 0 ]

}

@test "Test that var::equals returns 1 when var does not match input" {
    run var::equals "a" "b"
    [ "${status}" -eq 1 ]
}

@test "Test that var::equals returns 2 when invalid input" {
    run var::equals
    [ "${status}" -eq 2 ]

    run var::equals "a" "b" "c"
    [ "${status}" -eq 2 ]
}


##
## var::matches
##

@test "Test that var::matches returns 0 when var matches regex" {
    run var::matches "some" "."
    [ "${status}" -eq 0 ]
}

@test "Test that var::matches returns 1 when var does not match regex" {
    run var::matches "some" "a"
    [ "${status}" -eq 1 ]
}

@test "Test that var::matches returns 2 when invalid input" {
    run var::matches "some" "a" "c"
    [ "${status}" -eq 2 ]

    run var::matches
    [ "${status}" -eq 2 ]
}


##
## var::is_numeric
##

@test "Test that var::is_numeric returns 0 when var is numeric" {
    run var::is_numeric 134
    [ "${status}" -eq 0 ]

}

@test "Test that var::is_numeric returns 1 when var is not numeric" {
    run var::is_numeric abc
    [ "${status}" -eq 1 ]
}

@test "Test that var::is_numeric returns 2 when invalid input" {
    run var::is_numeric a b c
    [ "${status}" -eq 2 ]

    run var::is_numeric
    [ "${status}" -eq 2 ]
}


##
## var::is_alphanumeric
##

@test "Test that var::is_alphanumeric returns 0 when var is alphanumeric" {
    run var::is_alphanumeric abc1234
    [ "${status}" -eq 0 ]
}

@test "Test that var::is_alphanumeric returns 1 when var is not alphanumeric" {
    run var::is_alphanumeric abc1234!
    [ "${status}" -eq 1 ]
}

@test "Test that var::is_alphanumeric returns 2 when invalid input " {
    run var::is_alphanumeric a b c 1 2 3 4
    [ "${status}" -eq 2 ]

    run var::is_alphanumeric
    [ "${status}" -eq 2 ]
}


##
## var::is_alpha
##

@test "Test that var::is_alpha returns 0 when var is alpha" {
    run var::is_alpha abcd
    [ "${status}" -eq 0 ]
}

@test "Test that var::is_alpha returns 1 when var is not alpha" {
    run var::is_alpha 1234
    [ "${status}" -eq 1 ]
}

@test "Test that var::is_alpha returns 2 when invalid input" {
    run var::is_alpha
    [ "${status}" -eq 2 ]

    run var::is_alpha "a" "b" "c"
    [ "${status}" -eq 2 ]
}

##
## var::is_int
##

@test "Test that var::is_int returns 0 when var is an integer" {
    run var::is_int 1234
    [ "${status}" -eq 0 ]
}

@test "Test that var::is_int returns 1 when var is not an integer" {
    run var::is_int 1.00
    [ "${status}" -eq 1 ]
}

@test "Test that var::is_int returns 2 when invalid input" {
    run var::is_int "a" "b" "c"
    [ "${status}" -eq 2 ]

    run var::is_int
    [ "${status}" -eq 2 ]
}


##
## var::is_float
##

@test "Test that var::is_float returns 0 when var is a flotation" {
    run var::is_float 1.00
    [ "${status}" -eq 0 ]

    run var::is_float 1.2
    [ "${status}" -eq 0 ]
}

@test "Test that var::is_float returns 1 when var is not a flotation" {
    run var::is_float "1234"
    [ "${status}" -eq 1 ]

    run var::is_float "1"
    [ "${status}" -eq 1 ]
}

@test "Test that var::is_float returns 2 when invalid input" {
    run var::is_float "1" "2" "3" "4"
    [ "${status}" -eq 2 ]

    run var::is_float
    [ "${status}" -eq 2 ]
}


##
## var::all
##

@test "Test that var::all returns 0 when all are set" {
    run var::all "1" "2" "3"
    [ "${status}" -eq 0 ]

    run var::all "true" "true"
    [ "${status}" -eq 0 ]
}

@test "Test that var::all returns 1 when not all are set" {
    run var::all "" "1"
    [ "${status}" -eq 1 ]

    run var::all "1" ""
    [ "${status}" -eq 1 ]
}

@test "Test that var::all returns 2 when invalid input" {
    run var::all "0"
    [ "${status}" -eq 2 ]

    run var::all
    [ "${status}" -eq 2 ]
}


##
## var::any
##

@test "Test that var::any returns 0 when any is set" {
    run var::any "1" ""
    [ "${status}" -eq 0 ]

    run var::any "" "1"
    [ "${status}" -eq 0 ]
}

@test "Test that var::any returns 1 when not any is set" {
    run var::any "" ""
    [ "${status}" -eq 1 ]

    run var::any "" "" ""
    [ "${status}" -eq 1 ]
}

@test "Test that var::any returns 2 when invalid input" {
    run var::any
    [ "${status}" -eq 2 ]
}


##
## var::none
##

@test "Test that var::none returns 0 when none are set" {
    run var::none "" ""
    [ "${status}" -eq 0 ]
    run var::none "" "" ""
    [ "${status}" -eq 0 ]
    run var::none "" "" "" ""
    [ "${status}" -eq 0 ]
    run var::none "" "" "" "" ""
    [ "${status}" -eq 0 ]
}

@test "Test that var::none returns 1 when none are none" {
    run var::none "1" "1" "" ""
    [ "${status}" -eq 1 ]

    run var::none "1" "" "" ""
    [ "${status}" -eq 1 ]

    run var::none "" "1" "" ""
    [ "${status}" -eq 1 ]

    run var::none "a" "b" "c"
    [ "${status}" -eq 1 ]
}

@test "Test that var::none returns 2 when invalid input" {
    run var::none
    [ "${status}" -eq 2 ]

    run var::none "1"
    [ "${status}" -eq 2 ]
}


##
## var::lt
##

@test "Test that var::lt returns 0 when var1 is less than var2" {
    run var::lt 1 2
    [ "${status}" -eq 0 ]

    run var::lt 100 200
    [ "${status}" -eq 0 ]

    run var::lt 9 10
    [ "${status}" -eq 0 ]
}

@test "Test that var::lt returns 1 when var1 is not less than var2" {
    run var::lt 2 1
    [ "${status}" -eq 1 ]

    run var::lt 200 100
    [ "${status}" -eq 1 ]

    run var::lt 19 10
    [ "${status}" -eq 1 ]

    run var::lt 10 10
    [ "${status}" -eq 1 ]
}

@test "Test that var::lt returns 2 when invalid input" {
    run var::lt
    [ "${status}" -eq 2 ]

    run var::lt "A" "B"
    [ "${status}" -eq 2 ]

    run var::lt 200 100 50
    [ "${status}" -eq 2 ]
}

##
## var::le
##

@test "Test that var::le returns 0 when var1 is lower or equal to var2" {
    run var::le 1 1
    [ "${status}" -eq 0 ]

    run var::le 100 200
    [ "${status}" -eq 0 ]

    run var::le 9 10
    [ "${status}" -eq 0 ]
}

@test "Test that var::le returns 1 when var1 is not lower  or equal than var2" {
    run var::le 2 1
    [ "${status}" -eq 1 ]

    run var::le 200 100
    [ "${status}" -eq 1 ]

    run var::le 19 10
    [ "${status}" -eq 1 ]
}

@test "Test that var::le returns 2 when invalid input" {
    run var::le "a" "b"  "c"
    [ "${status}" -eq 2 ]

    run var::le "a" "b"
    [ "${status}" -eq 2 ]

    run var::le
    [ "${status}" -eq 2 ]
}

##
## var::gt
##

@test "Test that var::gt returns 0 when var1 is greater than var2" {
    run var::gt 2 1
    [ "${status}" -eq 0 ]

    run var::gt 200 100
    [ "${status}" -eq 0 ]

    run var::gt 19 10
    [ "${status}" -eq 0 ]
}

@test "Test that var::gt returns 1 when var1 is not greater than var2" {
    run var::gt 2 2
    [ "${status}" -eq 1 ]

    run var::gt 100 200
    [ "${status}" -eq 1 ]

    run var::gt 1 10
    [ "${status}" -eq 1 ]
}

@test "Test that var::gt returns 2 when invalid input" {
    run var::gt
    [ "${status}" -eq 2 ]

    run var::gt 200 100 50
    [ "${status}" -eq 2 ]

    run var::gt "a" "b"
    [ "${status}" -eq 2 ]
}


##
## var::ge
##

@test "Test that var::ge returns 0 when var1 is greater than var2" {
    run var::ge 2 2
    [ "${status}" -eq 0 ]

    run var::ge 200 100
    [ "${status}" -eq 0 ]

    run var::ge 19 10
    [ "${status}" -eq 0 ]
}

@test "Test that var::ge returns 1 when var1 is not greater than var2" {
    run var::ge 1 2
    [ "${status}" -eq 1 ]

    run var::ge 100 200
    [ "${status}" -eq 1 ]

    run var::ge 1 10
    [ "${status}" -eq 1 ]
}

@test "Test that var::ge returns 2 when invalid input" {
    run var::ge
    [ "${status}" -eq 2 ]

    run var::ge 200 100 50
    [ "${status}" -eq 2 ]

    run var::ge 19
    [ "${status}" -eq 2 ]

    run var::ge "A" "b"
    [ "${status}" -eq 2 ]
}

##
## var::eq
##

@test "Test that var::eq returns 0 when var1 is equal to var2" {
    run var::eq 2 2
    [ "${status}" -eq 0 ]

    run var::eq 100 100
    [ "${status}" -eq 0 ]

    run var::eq 10 10
    [ "${status}" -eq 0 ]
}

@test "Test that var::eq returns 1 when var1 is not equal to than var2" {
    run var::eq 1 2
    [ "${status}" -eq 1 ]

    run var::eq 100 200
    [ "${status}" -eq 1 ]

    run var::eq 1 10
    [ "${status}" -eq 1 ]
}

@test "Test that var::eq returns 2 when invalid input" {
    run var::eq
    [ "${status}" -eq 2 ]

    run var::eq 100 100 100
    [ "${status}" -eq 2 ]

    run var::eq 10
    [ "${status}" -eq 2 ]

    run var::eq "a" "b"
    [ "${status}" -eq 2 ]
}


##
## var::ne
##

@test "Test that var::ne returns 0 when var1 is not equal to var2" {
    run var::ne 2 3
    [ "${status}" -eq 0 ]

    run var::ne 100 200
    [ "${status}" -eq 0 ]

    run var::ne 19 10
    [ "${status}" -eq 0 ]
}

@test "Test that var::ne returns 1 when var1 is not not equal to than var2" {
    run var::ne 1 1
    [ "${status}" -eq 1 ]

    run var::ne 100 100
    [ "${status}" -eq 1 ]

    run var::ne 10 10
    [ "${status}" -eq 1 ]
}

@test "Test that var::ne returns 2 when invalid input" {
    run var::ne 2 3 4
    [ "${status}" -eq 2 ]

    run var::ne 100
    [ "${status}" -eq 2 ]

    run var::ne
    [ "${status}" -eq 2 ]

    run var::ne "a" "b"
    [ "${status}" -eq 2 ]
}


##
## var::sum
##

@test "Test that var::sum returns sum of vars" {
    output="$( var::sum 2 3 )"
    [ "${output}" -eq 5 ]

    output="$( var::sum 100 200 )"
    [ "${output}" -eq 300 ]

    output="$( var::sum 10 10 10 10 10 )"
    [ "${output}" -eq 50 ]

    run var::sum 2 3
    [ "${status}" -eq 0 ]
}

@test "Test that var::sum returns 2 when invalid input" {
    run var::sum 100 "a"
    [ "${status}" -eq 2 ]

    run var::sum
    [ "${status}" -eq 2 ]

    run var::sum "a" "b"
    [ "${status}" -eq 2 ]
}

##
## var::incr
##

@test "Test that var::incr returns incr of vars" {
    output="$( var::incr 2 )"
    [ "${output}" -eq 3 ]

    output="$( var::incr 100 )"
    [ "${output}" -eq 101 ]

    output="$( var::incr 2 2 )"
    [ "${output}" -eq 4 ]

    output="$( var::incr 3 -2 )"
    [ "${output}" -eq 1 ]

    output="$( var::incr -3 -2 )"
    [ "${output}" -eq -5 ]

    run var::incr 2
    [ "${status}" -eq 0 ]

    run var::incr 2 1
    [ "${status}" -eq 0 ]

    run var::incr 2 -1
    [ "${status}" -eq 0 ]
}

@test "Test that var::incr returns 2 when invalid input" {
    run var::incr 100 "a"
    [ "${status}" -eq 2 ]

    run var::incr
    [ "${status}" -eq 2 ]

    run var::incr "a" "b" "c"
    [ "${status}" -eq 2 ]

    run var::incr 1 2 3
    [ "${status}" -eq 2 ]
}

##
## var::decr
##

@test "Test that var::decr returns decrement of vars" {
    output="$( var::decr 2 )"
    [ "${output}" -eq 1 ]

    output="$( var::decr 100 )"
    [ "${output}" -eq 99 ]

    output="$( var::decr 3 2 )"
    [ "${output}" -eq 1 ]

    output="$( var::decr 3 -2 )"
    [ "${output}" -eq 5 ]

    output="$( var::decr -3 -2 )"
    [ "${output}" -eq -1 ]

    run var::decr 2
    [ "${status}" -eq 0 ]

    run var::decr 2 1
    [ "${status}" -eq 0 ]

    run var::decr 2 -1
    [ "${status}" -eq 0 ]
}

@test "Test that var::decr returns 2 when invalid input" {
    run var::decr 100 "a"
    [ "${status}" -eq 2 ]

    run var::decr
    [ "${status}" -eq 2 ]

    run var::decr "a" "b" "c"
    [ "${status}" -eq 2 ]

    run var::decr 1 2 3
    [ "${status}" -eq 2 ]
}

