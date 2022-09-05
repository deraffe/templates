#!/usr/bin/env bash
# add _logging_usage to usage and set {,RUN_}LOGLEVEL defaults


_msg() {
  echo -e "$@" >&2
}

_log() {
  _msg "[$(date '+%F %H:%M:%S')] ${1}"
}

_debug() {
  if [[ ${LOGLEVEL:-} -ge 4 ]]; then
    _log "DEBUG: $*"
  fi
}

_info() {
  if [[ ${LOGLEVEL:-} -ge 3 ]]; then
    _log "INFO: $*"
  fi
}

_warn() {
  if [[ ${LOGLEVEL:-} -ge 2 ]]; then
    _log "WARN: $*"
  fi
}

_error() {
  if [[ ${LOGLEVEL:-} -ge 1 ]]; then
    _log "ERROR: $*"
  fi
}

_die() {
  LOGLEVEL=1 _error "${1}"
  exit "${2-1}"
}

_run() {
  if [[ ${LOGLEVEL:-} -ge ${RUN_LOGLEVEL:-} ]]; then
    (
      set -x
      "$@"
    )
  else
    "$@"
  fi
}

_p() {
  [[ -n "${NO_COLOR:-}" ]] && return 0
  _ansi_color() {
    # see terminfo(5) for setaf/setab
    case "${1}" in
      black) printf 0;;
      red) printf 1;;
      green) printf 2;;
      yellow) printf 3;;
      blue) printf 4;;
      magenta) printf 5;;
      cyan) printf 6;;
      white) printf 7;;
    esac
  }

  _default_escape_codes() {
    # based on xterm
    case "${1}" in
      cub1) printf $'\b';; # move left one space
      cud1) printf $'\n';; # down one line
      cuu1) printf $'\e[A';; # up one line
      dch1) printf $'\e[P';; # delete character
      cvvis) printf $'\e[?12;25h';; # make cursor very visible
      civis) printf $'\e[?25l';; # make cursor invisible
      cnorm) printf $'\e[?12l\e[?25h';; # make cursor appear normal
      sgr0) printf $'\e(B\e[m';; # turn off all attributes
      sitm) printf $'\e[3m';; # enter italic mode
      smul) printf $'\e[4m';; # begin underline mode
      smso) printf $'\e[7m';; # begin standout mode
      setaf) printf $'\e'"[3$(_ansi_color "${1##fg_}")m";; # set foregound color to #1
      setab) printf $'\e'"[4$(_ansi_color "${1##fg_}")m";; # set background color to #1
      *) return 1;;
    esac
  }

  _tput() {
    if [[ -t 2 ]]; then
      tput "$1"
    else
      _default_escape_codes "$1"
    fi
  }


  case "$1" in
    back)
      _tput cub1
      ;;
    down)
      _tput cud1
      ;;
    up)
      _tput cuu1
      ;;
    del*)
      _tput dch1
      ;;
    cursor_highlight)
      _tput cvvis
      ;;
    cursor_invisible)
      _tput civis
      ;;
    cursor_normal)
      _tput cnorm
      ;;
    reset)
      _tput sgr0
      ;;
    ital*)
      _tput sitm
      ;;
    under*)
      _tput smul
      ;;
    standout)
      _tput smso
      ;;
    fg_*)
      _tput setaf "$1"
      ;;
    bg_*)
      _tput setab "$1"
      ;;
    *)
      _debug "Interpreting $1 as terminfo cap"
      _tput "$1"
      ;;
  esac
}

_fmt() {
  text="${1?Please provide text}"
  shift 1
  for f in "$@"; do
    $0 _p "$f"
  done
  printf "%s" "$text"
  $0 _p reset
}

_logging_usage() {
  cat >&2 <<-EOF
  $(_fmt "NO_COLOR" italics)
    If set, disables all escape-code formatting.

  $(_fmt "LOGLEVEL" italics)
    Numerical log level. 1 is $(_fmt "ERROR" ital), 2 is $(_fmt "WARN" ital), 3 is $(_fmt "INFO" ital) and 4 is $(_fmt "DEBUG" ital). Default is 2/$(_fmt "WARN" ital).

  $(_fmt "RUN_LOGLEVEL" italics)
    Numerical log level at which commands run will be printed to the console. Default is 3/$(_fmt "INFO" ital).
EOF
}

LOGLEVEL:=2
RUN_LOGLEVEL:=3

# vim: set ts=2 sw=2 et ft=bash :
