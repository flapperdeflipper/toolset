#!/usr/bin/env bash

function git::baseurl {
    local url

    if ! url="$( git remote -v | grep ^origin | awk '/push/ {print $2}' )"
    then
        proc::die "Failed to retrieve git remote url from repository"
    fi

    if var::is_empty "${url}"
    then
        proc::die "Failed to get url from git remote"
    fi

    if string::startswith "git@" "${url}"
    then
        url="$( sed \
            -e 's#:#/#g' \
            -e 's#git@#https://#' \
            -e 's#\.git##' <<< "${url}" \
        )"
    fi

   printf "%s\n" "${url}"
}


function git::provider_uri {
    local provider="${1}"
    local arguments="${2}"

    case "${provider}" in

        gitlab)
            case "${arguments}" in
                --pipe|-ci)
                    printf -- "pipelines"
                    ;;
                --ci-visual|-v)
                    printf -- "-/ci/editor?tab=1"
                    ;;
                --ci-lint|-cl)
                    printf -- "-/ci/editor?tab=2"
                    ;;
                --ci-merged|-cm)
                    printf -- "-/ci/editor?tab=2"
                    ;;
                --mr|--pr|-p)
                    printf -- "merge_requests"
                    ;;
                --ci|--config|-c)
                    printf -- "-/settings/ci_cd"
                    ;;
                --cr|--registry|-r)
                    printf -- "container_registry"
                    ;;
                --issues|-i)
                    printf -- "-/issues"
                    ;;
                *)
                    printf ""
                    ;;
            esac
            ;;

         github)
            case "${arguments}" in
                --pipe|-a)
                    printf "actions"
                    ;;
                --mr|-m|--pr|-p)
                    printf "pulls"
                    ;;
                --ci|--config|-c)
                    printf "settings/actions"
                    ;;
                --cr|--registry|-r)
                    printf "packages"
                    ;;
                --issues|-i)
                    printf "issues"
                    ;;
                *)
                    printf ""
                    ;;
            esac
            ;;

         bitbucket)
            case "${arguments}" in
                --pipe|-a)
                    printf "addon/pipelines/home"
                    ;;
                --mr|--pr|-p)
                    printf "pull-requests/"
                    ;;
                --ci|--config|-c)
                    printf "addons/pipelines/settings"
                    ;;
                --cr|--registry|-r)
                    printf ""
                    ;;
                --issues|-i)
                    printf "jira?statuses=new&statuses=indeterminate&sort=-updated&page=1"
                    ;;
                *)
                    printf ""
                    ;;
            esac
            ;;

         *)
             log::error "${FUNCNAME[0]}: Provider ${provider} unknown"
             return 1
         ;;
    esac
}


function git::is_dirty {
    if ! var::is_empty "$( git diff --stat )"
    then
        return 0
    fi

    return 1
}

function git::is_clean {
    if var::is_empty "$( git diff --stat )"
    then
        return 0
    fi

    return 1
}

function git::is_tag {
    local -r input="${1:-""}"

    if ! var::eq "${#}" 1 \
      || var::is_empty "${input}"
    then
        log::error "${FUNCNAME[0]}: Usage git::is_tag <tag>"
        return 2
    fi

    if ! ( git tag -l | grep -q "^${input}$" )
    then
        return 1
    fi

    return 0
}


function git::is_repo {
    if ! git rev-parse HEAD > /dev/null 2>&1
    then
        return 1
    fi

    return 0
}


################################################################################
## FZF Git helpers                                                            ##
################################################################################

function git::preview {
    fzf \
        --height 80% \
        --preview 'bat --color=always --style=numbers --line-range=:500 {}'
}


function git::fzf_down {
    fzf \
        --height 50% \
        --min-height 20 \
        --border \
        --bind ctrl-/:toggle-preview "$@"
}


function git::fzf_git_status {
    git::is_repo || return

    git -c color.status=always status --short \
    | git::fzf_down \
        -m \
        --ansi \
        --nth 2..,.. \
        --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' \
    | cut -c4- | sed 's/.* -> //'
}

function git::fzf_git_branch {
    git::is_repo || return

    git branch -a --color=always \
        | grep -v '/HEAD\s' \
        | sort \
        | git::fzf_down \
              --ansi \
              --multi \
              --tac \
              --preview-window right:70% \
              --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' \
        | sed 's/^..//' \
        | cut -d' ' -f1 \
        | sed 's#^remotes/##'
}

function git::fzf_git_tag {
    git::is_repo || return

    git tag --sort -version:refname \
        | git::fzf_down \
              --multi \
              --preview-window right:70% \
              --preview 'git show --color=always {}'
}

function git::fzf_git_show {
    git::is_repo || return

    git log \
        --date=short \
        --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" \
        --graph \
        --color=always \
        | git::fzf_down \
            --ansi \
            --no-sort \
            --reverse \
            --multi \
            --bind 'ctrl-s:toggle-sort' \
            --header 'Press CTRL-S to toggle sort' \
            --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' \
        | grep -o "[a-f0-9]\{7,\}"
}

function git::fzf_git_remote {
    git::is_repo || return

    git remote -v \
        | awk '{print $1 "\t" $2}' \
        | uniq \
        | git::fzf_down \
            --tac \
            --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' \
        | cut -d $'\t' -f1
}

function git::fzf_git_stash {
    git::is_repo || return

    git stash list \
        | git::fzf_down \
            --reverse \
            -d: \
            --preview 'git show --color=always {1}' \
            | cut -d: -f1
}
