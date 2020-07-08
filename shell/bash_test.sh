#!/usr/bin/env bash
# shunit2 tests
# https://github.com/kward/shunit2/

. ./bash.sh

testEquality() {
  assertEquals 1 1
}

# shellcheck source=/usr/bin/shunit2
. "$(which shunit2)"
