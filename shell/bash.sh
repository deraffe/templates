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
  if [[ ${LOGLEVEL} == "DEBUG" || ${LOGLVL} -ge 4 ]]; then
    log "DEBUG: $*"
  fi
}

info() {
  if [[ ${LOGLEVEL} == "INFO" || ${LOGLVL} -ge 3 ]]; then
    log "INFO: $*"
  fi
}

warn() {
  if [[ ${LOGLEVEL} == "WARN" || ${LOGLVL} -ge 2 ]]; then
    log "WARN: $*"
  fi
}

error() {
  if [[ ${LOGLEVEL} == "ERROR" || ${LOGLVL} -ge 1 ]]; then
    log "ERROR: $*"
  fi
}

run() {
  (
    set -x
    "$@"
  )
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
    Set to one of DEBUG, INFO, WARN or ERROR to influence the loglevel. Default is WARN.

  LOGLVL
    Numerical equivalent of LOGLEVEL. 1 is ERROR, 2 is WARN, 3 is INFO and 4 is DEBUG.
  "
}

cmd_example() {
  arg_one="${1:?Please provide an argument}"
  arg_two="${2:-}"
  debug "Example command"
  warn "Example warning: ${arg_one}"
  error "Example error (${arg_two})"
  run uname -a
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  LOGLEVEL="${LOGLEVEL:-WARN}"
  LOGLVL="${LOGLVL:-2}"
  case "${1:-}" in
    -h | --h*)
      usage
      ;;
    example)
      shift 1
      cmd_example "$@"
      ;;
    "" | *)
      usage
      exit 1
      ;;
  esac
fi
