#!/usr/bin/env bash
# shellcheck disable=SC2312,SC2016

function git::baseurl {
    local url

    if ! url="$( git remote -v | grep ^origin | awk '/push/ {print $2}' )"
    then
        exit::error "Failed to retrieve git remote url from repository"
    fi

    if var::is_empty "${url}"
    then
        exit::error "Failed to get url from git remote"
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


function git::sanity {
    local branch="${1}"
    local default_branch="${2}"

    if git::is_dirty
    then
        exit::error "Current workdir on ${branch} is dirty"
    fi

    if var::equals "${branch}" "${default_branch}" \
    && [[ "${#}" =~ fipo|mr|yolo|retag ]]
    then
        exit::error "Thou shall not push to ${default_branch}!"
    fi
}

git::inside_work_tree() {
    git rev-parse \
        --is-inside-work-tree \
        >/dev/null;
}

function git::basedir {
    git rev-parse \
        --show-toplevel
}

function git::branch {
    git rev-parse \
        --abbrev-ref HEAD
}


function git::default_branch {
    git remote show origin \
        | awk '/HEAD branch:/ { print $NF}'
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
    local -r input="${1:-}"

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
