#!/usr/bin/env bats

load "../../../bin/toolset"


##
## string::lower
##

@test "Test that string::lower converts a string to lowercase" {
    run string::lower "ABCD"
    [ "$status" -eq 0 ]
    [ "$output" = "abcd" ]
}

@test "Test that string::lower converts stdin to lowercase" {
    output="$( echo ABCD | string::lower )"

    [ "$?" -eq 0 ]
    [ "$output" = "abcd" ]
}

@test "Test that string::lower returns 1 when no input" {
    run string::lower ""
    [ "$status" -eq 1 ]

    run string::lower
    [ "$status" -eq 1 ]
}

@test "Test that string::lower returns 2 when invalid input" {
    run string::lower "a" "b"
    [ "$status" -eq 2 ]

    run string::lower "a" "b" "C" "D"
    [ "$status" -eq 2 ]
}


##
## string::upper
##

@test "Test that string::upper converts a string to uppercase" {
    run string::upper "abcd"

    [ "$status" -eq 0 ]
    [ "$output" = "ABCD" ]
}

@test "Test that string::upper converts stdin to uppercase" {
    output="$( echo abcd | string::upper )"

    [ "$?" -eq 0 ]
    [ "$output" = "ABCD" ]
}

@test "Test that string::upper returns 1 when no input" {
    run string::upper "abcd"
    [ "$status" -eq 0 ]

    run string::upper "abcd"
    [ "$status" -eq 0 ]

}

@test "Test that string::upper returns 2 when invalid input" {
    run string::upper "a" "b"
    [ "$status" -eq 2 ]

    run string::upper "a" "b" "C" "D"
    [ "$status" -eq 2 ]
}


##
## string::replace
##

@test "Test that string::replace replaces a string within a string" {
    run string::replace "abcd" "1234" "abcdefgh"
    [ "$status" -eq 0 ]
    [ "$output" = "1234efgh" ]

    run string::replace "abcd" "1234" "abcdefgh"
    [ "$status" -eq 0 ]
    [ "$output" = "1234efgh" ]

    run string::replace "some" "one" "something"
    [ "$status" -eq 0 ]
    [ "$output" = "onething" ]
}

@test "Test that string::replace returns 2 on invalid input" {
    run string::replace "some" "one"
    [ "$status" -eq 2 ]

    run string::replace "some"
    [ "$status" -eq 2 ]
}

##
## string::length
##

@test "Test that string::length returns the length of a string" {
    run string::length "abcd"
    [ "$status" -eq 0 ]
    [ "$output" -eq 4 ]

    run string::length "abcdefgh"
    [ "$status" -eq 0 ]
    [ "$output" -eq 8 ]

    run string::length "1234567890"
    [ "$status" -eq 0 ]
    [ "$output" -eq 10 ]
}

@test "Test that string::length returns the length of stdin" {
    output="$( echo abcd | string::length )"
    [ "$?" -eq 0 ]
    [ "$output" -eq 4 ]

    output="$( echo abcdefgh | string::length )"
    [ "$?" -eq 0 ]
    [ "$output" -eq 8 ]

    output="$( echo 1234567890 | string::length )"
    [ "$?" -eq 0 ]
    [ "$output" -eq 10 ]
}

@test "Test that string::length returns 1 when no input" {
    run string::length
    [ "$status" -eq 1 ]

    run string::length ""
    [ "$status" -eq 1 ]
}

@test "Test that string::length returns 2 when invalid input" {
    run string::length "a" "b"
    [ "$status" -eq 2 ]

    run string::length "" "" ""
    [ "$status" -eq 2 ]
}

##
## string::chomp
##

@test "Test that string::chomp strips carriage returns from a string" {
    run string::chomp "$( printf "aaaa\n" )"
    [ "$status" -eq 0 ]
    [ "$output" = "aaaa" ]

    run string::chomp "$( printf "aaaa\n\n" )"
    [ "$status" -eq 0 ]
    [ "$output" = "aaaa" ]
}

@test "Test that string::chomp strips carriage returns from stdin" {
    output="$( printf "aaaa\n" | string::chomp )"
    [ "$?" -eq 0 ]
    [ "$output" = "aaaa" ]

    output="$( printf "aaaa\n\n" | string::chomp )"
    [ "$?" -eq 0 ]
    [ "$output" = "aaaa" ]
}

@test "Test that string::chomp returns 1 when no input" {
    run string::chomp
    [ "$status" -eq 1 ]

    run string::chomp ""
    [ "$status" -eq 1 ]
}

@test "Test that string::chomp returns 2 when invalid input" {
    run string::chomp "" ""
    [ "$status" -eq 2 ]

    run string::chomp "a" "b"
    [ "$status" -eq 2 ]
}


##
## string::trim
##

@test "Test that string::trim strips all whitespace from a string" {
    run string::trim "    aaaa    "
    [ "$status" -eq 0 ]
    [ "$output" = "aaaa" ]

    run string::trim "    aaaa"
    [ "$status" -eq 0 ]
    [ "$output" = "aaaa" ]

    run string::trim "aaaa    "
    [ "$status" -eq 0 ]
    [ "$output" = "aaaa" ]
}

@test "Test that string::trim strips all whitespace from stdin" {
    output="$( printf "    aaaa    " | string::trim )"
    [ "$?" -eq 0 ]
    [ "$output" = "aaaa" ]

    output="$( printf "    aaaa" | string::trim )"
    [ "$?" -eq 0 ]
    [ "$output" = "aaaa" ]

    output="$( printf "aaaa    " | string::trim )"
    [ "$?" -eq 0 ]
    [ "$output" = "aaaa" ]
}

@test "Test that string::trim returns 1 when no input" {
    run string::trim
    [ "$status" -eq 1 ]

    run string::trim ""
    [ "$status" -eq 1 ]
}

@test "Test that string::trim returns 2 when invalid input" {
    run string::trim "" "" ""
    [ "$status" -eq 2 ]

    run string::trim "a" "b"
    [ "$status" -eq 2 ]
}


##
## string::lstrip
##

@test "Test that string::lstrip strips the prefix from a string" {
    run string::lstrip "foo"
    [ "$status" -eq 0 ]
    [ "$output" == "oo" ]

    run string::lstrip "foobar"
    [ "$status" -eq 0 ]
    [ "$output" == "oobar" ]
}

@test "Test that string::lstrip strips the prefix from stdin" {
    output="$( echo foobar | string::lstrip )"

    [ "$?" -eq 0 ]
    [ "$output" == "oobar" ]
}

@test "Test that string::lstrip returns 1 if no input" {
    run string::lstrip ""
    [ "$status" -eq 1 ]
    [ "$output" == "" ]

    run string::lstrip
    [ "$status" -eq 1 ]
    [ "$output" == "" ]
}

@test "Test that string::lstrip returns 2 if invalid input" {
    run string::lstrip "" ""
    [ "$status" -eq 2 ]

    run string::lstrip "a" "b" "c"
    [ "$status" -eq 2 ]
}

##
## string::rstrip
##

@test "Test that string::rstrip strips the prefix from a string" {
    run string::rstrip "foo"
    [ "$status" -eq 0 ]
    [ "$output" == "fo" ]

    run string::rstrip "foobar"
    [ "$status" -eq 0 ]
    [ "$output" == "fooba" ]
}

@test "Test that string::rstrip strips the prefix from stdin" {
    output="$( echo foobar | string::rstrip )"

    [ "$?" -eq 0 ]
    [ "$output" == "fooba" ]
}

@test "Test that string::rstrip returns 1 if no arguments" {
    run string::rstrip ""
    [ "$status" -eq 1 ]

    run string::rstrip
    [ "$status" -eq 1 ]
}

@test "Test that string::rstrip returns 2 if invalid arguments" {
    run string::rstrip "" ""
    [ "$status" -eq 2 ]

    run string::rstrip "a" "b" "c"
    [ "$status" -eq 2 ]
}


##
## string::strip_prefix
##

@test "Test that string::strip_prefix strips the prefix from a string" {
    run string::strip_prefix "" ""
    [ "$status" -eq 0 ]
    [ "$output" == "" ]

    run string::strip_prefix "" "foo"
    [ "$status" -eq 0 ]
    [ "$output" == "" ]

    run string::strip_prefix "foo" ""
    [ "$status" -eq 0 ]
    [ "$output" == "foo" ]

    run string::strip_prefix "foo" "bar"
    [ "$status" -eq 0 ]
    [ "$output" == "foo" ]

    run string::strip_prefix "foo=bar" "foo="
    [ "$status" -eq 0 ]
    [ "$output" == "bar" ]

    run string::strip_prefix "foo=bar" "*="
    [ "$status" -eq 0 ]
    [ "$output" == "bar" ]
}

@test "Test that string::strip_prefix returns 2 when invalid input" {
    run string::strip_prefix "foo=bar" "*=" "something"
    [ "$status" -eq 2 ]

    run string::strip_prefix "foo=bar"
    [ "$status" -eq 2 ]
}


##
## string::strip_suffix
##

@test "Test that string::strip_suffix strips the suffix from a string" {
  run string::strip_suffix "" ""
  [ "$status" -eq 0 ]
  [ "$output" == "" ]

  run string::strip_suffix "" "foo"
  [ "$status" -eq 0 ]
  [ "$output" == "" ]

  run string::strip_suffix "foo" ""
  [ "$status" -eq 0 ]
  [ "$output" == "foo" ]

  run string::strip_suffix "foo" "bar"
  [ "$status" -eq 0 ]
  [ "$output" == "foo" ]

  run string::strip_suffix "foo=bar" "=bar"
  [ "$status" -eq 0 ]
  [ "$output" == "foo" ]

  run string::strip_suffix "foo=bar" "=*"
  [ "$status" -eq 0 ]
  [ "$output" == "foo" ]
}

@test "Test that string::strip_suffix returns 1 when invalid input" {
  run string::strip_suffix "foo=bar"
  [ "$status" -eq 2 ]

  run string::strip_suffix "foo=bar" "=*" "wersgd"
  [ "$status" -eq 2 ]
}


##
## string::contains
##

@test "Test that string::contains returns 0 if string in string" {
    run string::contains "abcd" "abcd1234"
    [ "$status" -eq 0 ]
}

@test "Test that string::contains returns 1 if string not in string" {
    run string::contains "abcd" "12345678"
    [ "$status" -eq 1 ]
}

@test "Test that string::contains returns 2 on invalid input" {
    run string::contains "abcd" "12345678" "agetr"
    [ "$status" -eq 2 ]

    run string::contains "abcd"
    [ "$status" -eq 2 ]
}

##
## string::startswith
##

@test "Test that string::startswith returns 0 if string starts with char" {
    run string::startswith "a" "appelsap"
    [ "$status" -eq 0 ]
}


@test "Test that string::startswith returns 1 if string does not start with char" {
    run string::startswith "b" "appelsap"
    [ "$status" -eq 1 ]
}


@test "Test that string::startswith returns 2 on invalid input" {
    run string::startswith "b" "appelsap" "b"
    [ "$status" -eq 2 ]

    run string::startswith "b"
    [ "$status" -eq 2 ]
}


##
## string::endswith
##

@test "Test that string::endswith returns 0 if string ends with char" {
    run string::endswith "p" "appelsap"
    [ "$status" -eq 0 ]
}


@test "Test that string::endswith returns 1 if string does not end with char" {
    run string::endswith "e" "appelsap"
    [ "$status" -eq 1 ]
}

@test "Test that string::endswith returns 2 on invalid input" {
    run string::endswith "e" "appelsap" "b"
    [ "$status" -eq 2 ]

    run string::endswith "e"
    [ "$status" -eq 2 ]
}

##
## string::equals
##

@test "Test that string::equals returns 0 if string is equal to input" {
    run string::equals "a" "a"
    [ "$status" -eq 0 ]
}


@test "Test that string::equals returns 1 if string is not equal to input" {
    run string::equals "a" "b"
    [ "$status" -eq 1 ]
}

@test "Test that string::equals returns 2 on invalid input" {
    run string::equals "a"
    [ "$status" -eq 2 ]

    run string::equals "a" "b" "c"
    [ "$status" -eq 2 ]
}

##
## string::not
##

@test "Test that string::not returns 0 if string is not equal to input" {
    run string::not "a" "b"
    [ "$status" -eq 0 ]
}

@test "Test that string::not returns 1 if string is equal to input" {
    run string::not "a" "a"
    [ "$status" -eq 1 ]
}

@test "Test that string::not returns 2 on invalid input" {
    run string::not "a" "a" "b"
    [ "$status" -eq 2 ]

    run string::not "a"
    [ "$status" -eq 2 ]
}
