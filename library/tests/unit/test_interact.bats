#!/usr/bin/env bats

load "../../../bin/toolset"

##
## interact::prompt_bool
##

@test "Test that interact::prompt_bool returns 0 if input Y is given" {
  run interact::prompt_bool <<< "Y"

  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ Continue ]]
  [[ "${lines[0]}" =~ "y/N" ]]

  run interact::prompt_bool <<< "y"

  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ Continue ]]
  [[ "${lines[0]}" =~ "y/N" ]]
}


@test "Test that interact::prompt_bool returns 1 if input N is given" {
  run interact::prompt_bool <<< "N"

  [ "$status" -eq 1 ]
  [[ "${lines[0]}" =~ Continue ]]
  [[ "${lines[0]}" =~ "y/N" ]]

  run interact::prompt_bool <<< "n"

  [ "$status" -eq 1 ]
  [[ "${lines[0]}" =~ Continue ]]
  [[ "${lines[0]}" =~ "y/N" ]]
}


@test "Test that interact::prompt_bool returns 0 if -y and no input is given" {
  run interact::prompt_bool -y <<< " "

  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ Continue ]]
  [[ "${lines[0]}" =~ "Y/n" ]]
}

@test "Test that interact::prompt_bool returns 1 if -y and input N is given" {
  run interact::prompt_bool -y <<< "N"

  [ "$status" -eq 1 ]
  [[ "${lines[0]}" =~ Continue ]]
  [[ "${lines[0]}" =~ "Y/n" ]]

  run interact::prompt_bool -y <<< "n"

  [ "$status" -eq 1 ]
  [[ "${lines[0]}" =~ Continue ]]
  [[ "${lines[0]}" =~ "Y/n" ]]
}

@test "Test that interact::prompt_bool returns 1 if -y and input Y is given" {
  run interact::prompt_bool -y <<< "Y"

  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ Continue ]]
  [[ "${lines[0]}" =~ "Y/n" ]]

  run interact::prompt_bool -y <<< "y"

  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ Continue ]]
  [[ "${lines[0]}" =~ "Y/n" ]]
}

@test "Test that interact::prompt_bool returns 1 if -y and incorrect input is given" {
  run interact::prompt_bool -y <<< "AAAAA"

  [ "$status" -eq 1 ]
  [[ "${lines[0]}" =~ Continue ]]
  [[ "${lines[0]}" =~ "Y/n" ]]
}

@test "Test that interact::prompt_bool returns 1 if incorrect input is given" {
  run interact::prompt_bool <<< "AAAAA"

  [ "$status" -eq 1 ]
  [[ "${lines[0]}" =~ Continue ]]
  [[ "${lines[0]}" =~ "y/N" ]]
}


##
## interact::prompt_response
##

@test "Test that interact::prompt_response returns 0 if input is given" {
  run interact::prompt_response "question" "some" <<< example

  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ question ]]
  [[ "${lines[1]}" =~ "[some]" ]]
  [[ "${lines[1]}" =~ example ]]
}

@test "Test that interact::prompt_response returns 0 if input without default is given" {
  run interact::prompt_response "question" <<< example

  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ question ]]
  [[ "${lines[1]}" =~ example ]]
}

@test "Test that interact::prompt_response returns 2 if incorrect input" {
    run interact::prompt_response

    [ "$status" -eq 2 ]
}


##
## interact::usage
##

@test "Test that interact::usage returns 0 if -h is given" {
    local -a input=( --some --arguments -h )

    run interact::usage "${input[@]}"

    [ "$status" -eq 0 ]
}


@test "Test that interact::usage returns 0 if --help is given" {
    local -a input=( --some --arguments --help )

    run interact::usage "${input[@]}"

    [ "$status" -eq 0 ]
}


@test "Test that interact::usage returns 1 if -h or --help is not given" {
    local -a input=( --some --arguments )

    run interact::usage "${input[@]}"

    [ "$status" -eq 1 ]
}

@test "Test that interact::usage returns 2 if incorrect input" {
    run interact::usage

    [ "$status" -eq 2 ]
}

