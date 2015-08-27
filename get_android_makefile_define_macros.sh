#!/usr/bin/env bash
# Author: Goldie Lin
# Usage: cd to Android root and run this script.

set -e
# Any subsequent commands which fail will cause the shell script to exit immediately

# Variable definitions
# ====================

readonly def_file="build/core/definitions.mk"
readonly out_file="android_makefile_define_macros.list"

# Function definitions
# ====================

check_pwd() {
  if [[ ! -d ".repo" ]]; then
    echo >&2 "Error: Please cd to Android root and run again."
    return 1
  fi
}

gen_def_list() {
  local def_list=""

  def_list="$(grep '^define' "${def_file}" | cut -d' ' -f2- | sort -u)"
  echo "${def_list}" > "${out_file}"
  echo "Save to file: '${out_file}'"
}

main() {
  check_pwd
  gen_def_list
}

main "$@"
