#!/usr/bin/env bash
# exit on error, exit on undefined variables, error on failing pipe commands
set -euo pipefail
# error on commands in command substitutions
shopt -s inherit_errexit # bash >= 4.4

echo2() {
  echo "$@" >&2
}

log() {
  echo2 "[$(date '+%F %H:%M:%S')] ${1}"
}

debug() {
  if [[ ${LOGLEVEL} -ge 4 ]]; then
    log "DEBUG: $*"
  fi
}

info() {
  if [[ ${LOGLEVEL} -ge 3 ]]; then
    log "INFO: $*"
  fi
}

warn() {
  if [[ ${LOGLEVEL} -ge 2 ]]; then
    log "WARN: $*"
  fi
}

error() {
  if [[ ${LOGLEVEL} -ge 1 ]]; then
    log "ERROR: $*"
  fi
}

run() {
  (
    set -x
    "$@"
  )
}

get_script_dir() {
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

cleanup() {
  info "Cleaning up..."
  info "Done."
}

usage() {
  echo2 "${BASH_SOURCE[0]} [options] {command}

  OPTIONS

  -h --help
    Display this message.

  COMMANDS

  example {arg_one} [arg_two]
    An example command

  ENVIRONMENT

  LOGLEVEL
    Numerical log level. 1 is ERROR, 2 is WARN, 3 is INFO and 4 is DEBUG. Default is 2/WARN.

  "
}

cmd_example() {
  local arg_one="${1:?Please provide an argument}"
  local arg_two="${2:-}"
  debug "Example command"
  warn "Example warning: ${arg_one}"
  error "Example error (${arg_two})"
  run uname -a
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  : "${LOGLEVEL:=2}"
  case "${1:-}" in
    -h | --h*)
      usage
      ;;
    example)
      trap cleanup EXIT
      shift 1
      cmd_example "$@"
      ;;
    "" | *)
      usage
      exit 1
      ;;
  esac
fi
