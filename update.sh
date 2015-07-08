#!/usr/bin/env bash
# Author: Goldie Lin
# Requirements: git, repo (Android git-repo)
# Usage: Simply run `./update.sh`

set -e
# Any subsequent commands which fail will cause the shell script to exit immediately

# Variable definitions
# ====================

# command options
readonly git_gc_enable="no" # yes or no
declare -ra git_gc_opt=() # (empty) or --aggressive
declare -ra git_pull_opt=()
declare -ra repo_sync_opt=( -q -f )

# git clone list: title, url
declare -rA git_clone_list=( \
  ["vimrc"]="git://github.com/goldie-lin/vimrc.git"
  ["dotfiles"]="git://github.com/goldie-lin/dotfiles.git"
  ["binfiles"]="git://github.com/goldie-lin/binfiles.git"
  ["repo"]="https://gerrit.googlesource.com/git-repo"
  ["bash-completion-repo"]="git://github.com/aartamonau/repo.bash_completion.git"
  ["bash-completion-android"]="git://github.com/mbrubeck/android-completion.git"
  ["urxvt-perls"]="git://github.com/muennich/urxvt-perls.git"
  ["fb-adb"]="git://github.com/facebook/fb-adb.git"
  ["vim-plug"]="git://github.com/junegunn/vim-plug.git"
  ["icdiff"]="git://github.com/jeffkaufman/icdiff.git"
  ["abs"]="git://github.com/deanboole/abs.git"
  ["Linux-tips"]="git://github.com/deanboole/Linux-tips.git"
  ["busybox-android-ndk"]="git://github.com/tias/android-busybox-ndk.git"
  ["busybox"]="git://git.busybox.net/busybox.git"
  ["crosstool-ng"]="git://github.com/crosstool-ng/crosstool-ng.git"
  ["git"]="git://github.com/git/git.git"
  ["linux"]="git://github.com/torvalds/linux.git"
  ["shellcheck"]="git://github.com/koalaman/shellcheck.git"
  ["crash"]="git://github.com/crash-utility/crash.git"
  ["tmuxinator"]="git://github.com/tmuxinator/tmuxinator.git"
)

# git pull list: title, path
declare -rA git_pull_list=( \
  ["vimrc"]="${HOME}/opt/vimrc"
  ["dotfiles"]="${HOME}/opt/dotfiles"
  ["binfiles"]="${HOME}/opt/binfiles"
  ["repo"]="${HOME}/opt/git-repo"
  ["bash-completion-repo"]="${HOME}/opt/repo.bash_completion"
  ["bash-completion-android"]="${HOME}/opt/android-completion"
  ["urxvt-perls"]="${HOME}/opt/urxvt-perls"
  ["fb-adb"]="${HOME}/opt/fb-adb"
  ["vim-plug"]="${HOME}/opt/vim-plug"
  ["icdiff"]="${HOME}/opt/icdiff"
  ["abs"]="${HOME}/opt/abs"
  ["Linux-tips"]="${HOME}/opt/Linux-tips"
  ["busybox-android-ndk"]="${HOME}/opt/busybox/android-busybox-ndk"
  ["busybox"]="${HOME}/opt/busybox/busybox"
  ["crosstool-ng"]="${HOME}/opt/crosstool-ng/src"
  ["git"]="${HOME}/opt/git"
  ["linux"]="${HOME}/opt/linux"
  ["shellcheck"]="${HOME}/opt/shellcheck"
  ["crash"]="${HOME}/opt/crash"
  ["tmuxinator"]="${HOME}/opt/tmuxinator"
)

# repo init list: title, url
declare -rA repo_init_list=( \
  ["Android (AOSP)"]="https://android.googlesource.com/platform/manifest"
)

# repo sync list: title, path
declare -rA repo_sync_list=( \
  ["Android (AOSP)"]="${HOME}/opt/android-aosp"
)

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

echo_title() {
  echo -e "\n${cGreen}${*}${cClean}"
}

_get_linux_distro_name() {
  local -r _os="$(uname -s)"

  if [ "${_os}" = "Linux" ]; then
    if [ -f /etc/lsb-release ]; then
      # TODO: Should we trust the lsb_release command?
      lsb_release -s -i
    elif [ -f /etc/arch-release ]; then
      echo "Arch"
    elif [ -f /etc/debian_version ]; then
      echo "Debian"
    elif [ -f /etc/redhat-release ]; then
      echo "RedHat"
    elif [ -f /etc/SuSE-release ]; then
      echo "SuSE"
    else
      echo "Unknown"
    fi
  else
    echo "NonLinux"
  fi
}

_get_python_variant_for_repo() {
  local _python="python"
  local _python_version=""
  local _returncode="0"

  # Current repo utility only support Python verion 2.6 - 2.7
  # TODO: Maybe need to update this version check in the future.
  _python_version="$(python -V |& sed 's/Python//g;s/\s\+//g')"
  if [[ ! "${_python_version}" =~ ^2\.(6|7)\..*$ ]]; then
    if hash "python2.7" 2>/dev/null; then
      _python="python2.7"
    elif hash "python2.6" 2>/dev/null; then
      _python="python2.6"
    else
      echo >&2 "Unaccepted version of $(python -V) for repo utility"
      _returncode="1"
    fi
  fi

  echo "${_python}"
  return "${_returncode}"
}

git_clone() {
  local -r _url="$1"
  local -r _path="$2"

  git clone "${_url}" "${_path}"
  git -C "${_path}" config --unset branch.master.rebase
}

git_pull() {
  local -r _path="$1"

  git -C "${_path}" pull "${git_pull_opt[@]}"
  if [[ "${git_gc_enable}" == "yes" ]]; then
    git -C "${_path}" gc "${git_gc_opt[@]}" || true  # Do not abort, ignore exit code
  fi
}

repo_init() {
  local -r _path="$1"
  local -r _url="$2"
  local -r _repo="$(which repo)"
  local -r _python="$(_get_python_variant_for_repo)"

  mkdir -p "${_path}"
  cd "${_path}"
  "${_python}" "${_repo}" init -u "${_url}"
}

repo_sync() {
  local -r _path="$1"
  local -r _repo="$(which repo)"
  local -r _python="$(_get_python_variant_for_repo)"

  cd "${_path}"
  "${_python}" "${_repo}" sync "${repo_sync_opt[@]}"
}

do_git_pull_list() {
  local _title=""
  local _path=""
  local _url=""

  for _title in "${!git_pull_list[@]}"; do
    _path="${git_pull_list[$_title]}"
    _url="${git_clone_list[$_title]}"
    echo_title "${_title}"
    if [[ -d "${_path}" ]]; then
      git_pull "${_path}"
    else
      git_clone "${_url}" "${_path}"
    fi
  done
}

do_repo_sync_list() {
  local _title=""
  local _path=""
  local _url=""

  for _title in "${!repo_sync_list[@]}"; do
    _path="${repo_sync_list[$_title]}"
    _url="${repo_init_list[$_title]}"
    echo_title "${_title}"
    if [[ ! -d "${_path}" ]]; then
      repo_init "${_path}" "${_url}"
    fi
    repo_sync "${_path}"
  done
}

do_update_vim_plugins() {
  # update via junegunn/vim-plug plugin manager
  vim -c 'PlugUpdate | q | q'
}

do_update_sys_pkgs() {
  local -r _distro="$(_get_linux_distro_name)"

  case "${_distro}" in
  "Arch")
    if hash "yaourt" 2>/dev/null; then
      echo_title "yaourt"
      yaourt -Syua
    else
      echo_title "pacman"
      sudo pacman -Syu
    fi
    ;;
  "Ubuntu")
    echo_title "apt"
    sudo apt-get update && sudo apt-get dist-upgrade
    ;;
  *)
    echo_title "Error: Unknown disro '${_distro}' to update system packages!"
    ;;
  esac
}

main() {
  do_update_sys_pkgs
  do_update_vim_plugins
  do_git_pull_list
  do_repo_sync_list
}

main "$@"
