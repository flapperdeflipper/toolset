# toolset

A bash library and toolset used for devops tasks and platform infrastructure on
mac osx.

This toolset is a set of tools, functions and libraries to make bash scripts a bit easier to
read, faster to develop and avoids some of the large pitfals that come with shell
scripting in bash.

It is a part of my dotfiles and configuration setup that I use for my personal and work computers, 
by splitting this set and my dotfiles, which are private I want to reduce the complexity of my local setup 
and hope that other people can make use of this set of tools.

I use it myself personally for both shell scripts and as the daily toolset by loading the
libraries in my environment through my `bashrc`.

I expect that some of the dependencies are not fully listed.

I'm open to merge requests for useful additions.

## Setup

This set of tools relies massively on `homebrew` and `bash 5`.

To get started, clone this repository:

```
git clone https://github.com/flapperdeflipper/toolset.git ~/.toolset
```

### Add the toolset/bin directory to your PATH

To make the utils accessible, make sure the `bin` directory is added in your
path variable:

```
export PATH="${HOME}/.toolset/bin:$PATH"
```

This will only change the path in your current environment, to get it to work on
all environments, without having to run the command every time, add it to your
`bashrc` file:

```
echo -e 'PATH="${HOME}/.toolset/bin:$PATH' >> ~/.bashrc
```

### Install homebrew

```
/bin/bash -c "$(
  curl -fsSL \
    https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
)"
```

### Install xcode command line tools

```
touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
softwareupdate -i -a
rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
```

### Install the required utilities

```
brew bundle install --file=Brewfile
```

### [optional] Configure the homebrew bash version for your useraccount

If you want to use the toolset in your shell environment, make sure that you
configure the recent bash shell from homebrew as login shell for your user account.

```
echo /usr/local/bin/bash | sudo tee -a /etc/shells
```

And in `System Preferences->Users & Groups` right click on your username and
select advanced options. In the window select the newer shell as the login
shell.

### Symlink the gnu coreutils to user local

homebrew prefixes all coreutils with a `g`, which is terribly annoying when
working on both linux and mac terminals, so instead we'll symlink the used gnu
coreutils in `/usr/local/bin`.

First, create a `~/.gnulinks` file with all the utils that should be symlinks:
```
cat > ~/.gnulinks <<EOF
awk
egrep
fgrep
find
grep
indent
locate
sed
tar
time
updatedb
xargs
mktemp
readlink
EOF
```

And after that, run the `update-symlinks` script:
```
~/.toolset/bin/update-symlinks
```



## Tools overview

The `tools` utility in the bin directory provides an overview of all tools that
are available in this toolset.

To work well with this utility, all scripts should have a `-h` and `--help`
argument that prints a usage section to the screen.


## Scripting

In the `bin/` directory there are multiple examples of how to use this util set.


## Unit tests

A large part of the toolset is tested using
[bats-core](bats-core.readthedocs.io). To run the testsuite, source the toolset
using `source ~/.toolset/bin/toolset` and run `tests::runtests`


# Sanity checks

Other than unit tests, that are only executed on request by executing the

specific command, sanity checks can be used when you source the toolset in your
shell environment to run every time a new session is opened.
It checks a set of conditions that are required for maximum success.

The sanity checks can be manually executed by running `sanity::run -v`.
This will output the verbose output of all executed sanity checks.

As sanity checks are run on every new session, slow checks can have a lot of
impact on the startup time of your new shell.

Sanity checks are run by sourcing all `*.sh` files in the `$SANITY_CHECK_PATH` directory.
All defined functions that are prefixed with `sanity::check::`
will be executed one by one.

As the checks are run with all library files included (sourced), you can use all
utils in our checks.

Example:
```
function sanity::check::check_that_homebrew_prefix_exists() {
   if ! fs::is_dir "${HOMEBREW_PREFIX}"
   then
      log::error "${FUNCNAME[0]}: HOMEBREW_PREFIX ${HOMEBREW_PREFIX} not found!"
      return 1
   fi

   return 0
}
```

The sanity check runner can be found in the bash library in `sanity.sh`


## Inspiration, sources

Many functions of this library have been seen in other libraries and adapted to
be used in this set of tools.

This set of utils was heavily inspired by
[libshell](https://github.com/legionus/libshell) and
[bashio](https://github.com/hassio-addons/bashio) and some functions and
libraries have been used in adapted form for use in this toolset.
