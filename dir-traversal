#!/usr/bin/env bash
# Author: Goldie Lin
# Description: BASH-ish directory traversal.
# Currect purposes:
#   * Ignored all files, just check the directories.
#   * Traversal the whole directory structure.
#   * Find out all the leaf and non-leaf directories. (Printed)
# References:
#   [1] http://mywiki.wooledge.org/ArithmeticExpression

set -e
# Any subsequent commands which fail will cause the shell script to exit immediately

# Variable definitions
# ====================

# color code
readonly cClean=$'\e[0m'
readonly cBlack=$'\e[30m'
readonly cDarkRed=$'\e[31m'
readonly cDarkGreen=$'\e[32m'
readonly cDarkYellow=$'\e[33m'
readonly cDarkBlue=$'\e[34m'
readonly cDarkPurple=$'\e[35m'
readonly cDarkCyan=$'\e[36m'
readonly cLightGray=$'\e[37m'
readonly cGray=$'\e[30;1m'
readonly cRed=$'\e[31;1m'
readonly cGreen=$'\e[32;1m'
readonly cYellow=$'\e[33;1m'
readonly cBlue=$'\e[34;1m'
readonly cPurple=$'\e[35;1m'
readonly cCyan=$'\e[36;1m'
readonly cWhite=$'\e[37;1m'

# Function definitions
# ====================

# if it has any subdir, then return zero (true), otherwise non-zero (false).
#has_subdir() {
#  local -r path="$1"
#  local -r subdir_count="$(find "${path}" -mindepth 1 -maxdepth 1 -type d | wc -l)" # default find won't follow symlinks, unless "-L" option
#  test "${subdir_count}" -gt 0
#}

# down search recursively, likes dfs.
down_search() {
  local -r lvl="$1"
  local -r path="$2"
  local -i i=0
  local -a subdirs=()
  local j=""

  while IFS= read -r -d $'\0' j; do
    subdirs[i++]="$j" # array indices are numeric context, will force arithmetic evaluation [1]
  done < <(find "${path}" -mindepth 1 -maxdepth 1 -type d -print0) # default find won't follow symlinks, unless "-L" option

  #local -r rst_dotglob="$(shopt -p dotglob)" || true # Get restoration command
  #shopt -s dotglob # Set shell option
  #for j in "${path}"/*; do
  #  [[ -d "$j" && ! -L "$j" ]] && subdirs[i++]="$j" # array indices are numeric context, will force arithmetic evaluation [1]
  #done
  #${rst_dotglob} # Restore shell option

  #if has_subdir "$path"; then
  if [[ "${#subdirs[@]}" -gt 0 ]]; then
    echo "[${cDarkCyan}${lvl}${cClean}][${cDarkGreen}non-leaf${cClean}] '${path}' ${cDarkGreen}(${#subdirs[@]})${cClean}"
    for ((i=0; i<${#subdirs[@]}; i++)); do
      down_search "$(( lvl+1 ))" "${subdirs[$i]}"
    done
  else
    echo "[${cDarkCyan}${lvl}${cClean}][${cDarkYellow}leaf-dir${cClean}] '${path}'"
  fi
}

main() {
  if [[ -d "$1" ]]; then
    down_search 0 "$1"
  else
    down_search 0 .
  fi
}

main "$@"
