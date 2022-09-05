#!/usr/bin/env bash

_is_root() {
  [[ $EUID -eq 0 ]]
}

_has_sudo_access() {
  if sudo -v; then
    sudo_euid="$(sudo -H -- "$BASH" -c 'printf "%s" "$EUID"')"
    if [[ $sudo_euid -eq 0 ]]; then
      return 0
    else
      return 1
    fi
  else
    return 2
  fi
}

_has_cap() {
  capsh --has-p="${1}" 2> /dev/null
}

_with_cap() {
  capability="${1:?Please provide one capability name}"
  shift 1
  if ! $0 _has_cap "$capability"; then
    sudo \
      -E \
      --preserve-env "USER,LOGNAME" \
      -- \
      capsh \
      --user="$USER" \
      --keep=1 \
      --caps="${capability}=ip" \
      --addamb="${capability}" \
      -- "$@"
    _debug "$(capsh --current)"
  else
    _debug "Already have capability ${capability}"
    "$@"
  fi
}
