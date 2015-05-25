#!/usr/bin/env bash
# Author: Goldie Lin
# Usage: cd to Android root and run this script.

set -e
# Any subsequent commands which fail will cause the shell script to exit immediately

# Variable definitions
# ====================

def_file="build/core/definitions.mk"
out_file="android_makefile_define_macros.list"

# Function definitions
# ====================

check_pwd() {
  [[ ! -f "Makefile" ]] && echo >&2 "Makefile not found! (Please cd to Android root)" && return 1
}

gen_def_list() {
  local def_list=""

  def_list="$(grep '^define' "${def_file}" | cut -d' ' -f2- | sort -u)"
  echo "${def_list}" | tee "${out_file}"
}

main() {
  check_pwd
  gen_def_list
}

main "$@"
