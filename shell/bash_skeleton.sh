#!/usr/bin/env bash

set -Eeuo pipefail
trap _cleanup SIGINT SIGTERM ERR EXIT

if [[ -n "${DEBUG:-}" ]]; then
  set -x
fi

_dummy() {
  # declares a dummy version of a function
  # Warning: function will persist in environment afterwards until redefined
  name="${1}"
  objtype="${2}"
  case "$objtype" in
    function)
      [[ $(type -t "$name") == "function" ]] || eval "${name}(){ :; }";;
  esac
}

_is_bash_version() {
  # test if bash is at least this version

  # optional dependency: logging
  _dummy debug function
  major="${1}"
  minor="${2}"
  debug "Requiring Bash ${major}.${minor}"
  [[ ${BASH_VERSINFO[0]} -gt "${major}" \
    || ${BASH_VERSINFO[0]} -eq "${major}" \
    && ${BASH_VERSINFO[1]} -ge "${minor}" ]]
}

if _is_bash_version 4 4; then
  shopt -s inherit_errexit
fi

_get_script_dir() {
  # cross-platform way of getting the current directory
  # https://stackoverflow.com/a/246128
  local SOURCE DIR
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$(cd -P "$(dirname "$SOURCE")" > /dev/null 2>&1 && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  DIR="$(cd -P "$(dirname "$SOURCE")" > /dev/null 2>&1 && pwd)"
  echo "$DIR"
}

_cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # optional dependency: logging
  _dummy info function
  info "Cleaning up..."
  info "Done."
}

usage() {
  # show usage message

  # optional dependency: logging
  if [[ $(type -t fmt) != "function" ]]; then
    _fmt() { echo "$1"; }
  fi
  cat >&2 <<-EOF
Usage: $(basename ${BASH_SOURCE[0]}) [FIXME options] {FIXME command}

  FIXME Description

OPTIONS

  $(_fmt "-h, --help" italics) Display this message.

COMMANDS

  $(_fmt "example {arg_one} [arg_two]" italics)
    An example command

ENVIRONMENT

  $(_fmt "DEBUG" italics)
    Turn on shell debugging.
EOF
}


# YOUR CODE HERE


if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  if [[ $(type -t "${1:-}") == function ]]; then
    # use dispatch pattern
    # https://www.oilshell.org/blog/2020/02/good-parts-sketch.html
    "$@"
  else
    case "${1:-}" in
      -h | --h*)
        usage
        ;;
      "" | *)
        usage
        exit 1
        ;;
    esac
  fi
fi

# vim: set ts=2 sw=2 et ft=bash :
