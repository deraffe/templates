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
  if [[ ${LOGLEVEL} -ge ${RUN_LOGLEVEL} ]]; then
    (
      set -x
      "$@"
    )
  else
    "$@"
  fi
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

p() {
  case "$1" in
    back)
      tput cub1
      ;;
    down)
      tput cud1
      ;;
    up)
      tput cuu1
      ;;
    del*)
      tput dch1
      ;;
    cursor_highlight)
      tput cvvis
      ;;
    cursor_invisible)
      tput civis
      ;;
    cursor_normal)
      tput cnorm
      ;;
    reset)
      tput sgr0
      ;;
    ital*)
      tput sitm
      ;;
    under*)
      tput smul
      ;;
    standout)
      tput smso
      ;;
    *)
      debug "Interpreting $1 as terminfo cap"
      tput "$1"
      ;;
  esac
}

fmt() {
  text="${1?Please provide text}"
  shift 1
  for f in "$@"; do
    p "$f"
  done
  printf "%s" "$text"
  p reset
}

usage() {
  echo2 "${BASH_SOURCE[0]} [options] {command}

  $(fmt "OPTIONS" bold underline)

  $(fmt "-h --help" italics)
    Display this message.

  $(fmt "COMMANDS" bold underline)

  $(fmt "example {arg_one} [arg_two]" italics)
    An example command

  $(fmt "ENVIRONMENT" bold underline)

  $(fmt "LOGLEVEL" italics)
    Numerical log level. 1 is $(fmt "ERROR" ital), 2 is $(fmt "WARN" ital), 3 is $(fmt "INFO" ital) and 4 is $(fmt "DEBUG" ital). Default is 2/$(fmt "WARN" ital).

  $(fmt "RUN_LOGLEVEL" italics)
    Numerical log level at which commands run will be printed to the console. Default is 3/$(fmt "INFO" ital).
  "
}

cleanup() {
  info "Cleaning up..."
  info "Done."
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
  : "${RUN_LOGLEVEL:=3}"
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
