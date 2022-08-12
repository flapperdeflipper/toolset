#!/usr/bin/env bash
# vi: ft=bash
# shellcheck shell=bash disable=SC2048

aws::s3::get_all_buckets() {
    local arguments=("${@}")
    aws::cli 3api list-buckets \
        --output text  \
        --query 'Buckets[].[Name]' \
        "${arguments[*]}"
}
