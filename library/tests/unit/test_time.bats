#!/usr/bin/env bats

load "../../../bin/toolset"


##
## time::human_readable_seconds
##

@test "Test that time::human_readable_seconds returns a human readable format" {
    [ "$( time::human_readable_seconds 12333 )" == "3 hours 25 minute(s) and 33 seconds" ]
}
