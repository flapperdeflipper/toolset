#!/usr/bin/env bats

load "../../../bin/toolset"


##
## net::is_ip4
##

@test "Test that net::is_ip4 returns 0 when ip address is a valid ipv4" {
    run net::is_ip4 "8.8.8.8"
    [ "$status" -eq 0 ]

    run net::is_ip4 "10.0.0.2"
    [ "$status" -eq 0 ]

    run net::is_ip4 "10.0.0.254"
    [ "$status" -eq 0 ]

    run net::is_ip4 "192.168.0.1"
    [ "$status" -eq 0 ]

    run net::is_ip4 "172.16.15.254"
    [ "$status" -eq 0 ]

    run net::is_ip4 "8.8.4.4"
    [ "$status" -eq 0 ]
}

@test "Test that net::is_ip4 returns 1 when ip address is not a valid ipv4" {
    run net::is_ip4 "256.255.255.255"
    [ "$status" -eq 1 ]

    run net::is_ip4 "555.555.555.555"
    [ "$status" -eq 1 ]

    run net::is_ip4 "8.8.4.2000"
    [ "$status" -eq 1 ]
}


##
## net::is_ip6
##

@test "Test that net::is_ip6 returns 0 when ip address is a valid ipv6" {
    run net::is_ip6 fe80::5f14:4519:47d2:da1
    [ "$status" -eq 0 ]
}

@test "Test that net::is_ip6 returns 1 when ip address is not a valid ipv6" {
    run net::is_ip6 plop
    [ "$status" -eq 1 ]
}


##
## net::is_fqdn
##

@test "Test that net::is_fqdn returns 0 when host is a valid FQDN" {
    run net::is_fqdn "abcd.com"
    [ "$status" -eq 0 ]
}

@test "Test that net::is_fqdn returns 1 when host is not a valid FQDN" {
    run net::is_fqdn "abcd"
    [ "$status" -eq 1 ]
}


##
## net::is_email
##

@test "Test that net::is_email returns 0 when address is a valid email" {
    run net::is_email 'joke@example.com'
    [ "$status" -eq 0 ]
}

@test "Test that net::is_email returns 1 when address is not a valid email" {
    run net::is_email "abcd"
    [ "$status" -eq 1 ]
}
