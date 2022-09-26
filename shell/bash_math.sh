#!/usr/bin/env bash

_calc() {
  (
    # shellcheck disable=SC2030
    LC_ALL=C
    printf "%.2f" "$(bc -l <<< "$@")"
  )
}
