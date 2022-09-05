#!/usr/bin/env bash

_support_assoc_arrays() {
  # associative array support was added in 4.0
  $0 _is_bash_version 4 0
}

_contains() {
  # check if $1 is contained in rest of args (e.g., an expanded array)
  local needle="${1:?Provide needle}"
  shift 1
  for e; do
    [[ $e == "$needle" ]] && return 0
  done
  return 1
}
