#!/usr/bin/env bash

shopt -s nullglob

is_installed() {
  command -v "$1" > /dev/null 2>&1
}

is_dry_run() {
  [ -n "$DRY_RUN" ]
}

delete() {
  if is_dry_run; then
    echo "removing $1"
  else
    rm -f "$1"
  fi
}

uninstall() {
  if is_dry_run; then
    echo "uninstalling $1"
  else
    brew uninstall "$1"
  fi
}

uninstall_git_secrets() {
  if ! is_installed "git-secrets"; then
    echo "git-secrets is not installed!"
    return
  fi

  case $(uname -s) in
    Darwin)
      uninstall git-secrets
      ;;
    Linux)
      delete "$(which git-secrets)"
      ;;
    *)
      echo "Could not recognize operating system!"
      exit 1
  esac
}

uninstall_git_hooks() {
  if ! is_installed "git-hooks"; then
    echo "git-hooks is not installed!"
    return
  fi

  delete "$(which git-hooks)"
}

remove_git_secrets_hook_file() {
  delete /usr/local/share/githooks/*/00-git-secrets

  count=$(find /usr/local/share/githooks -type f | grep -c -v "00-git-secrets")

  if [ "${count}" -ne "0" ]; then
    echo "Found extra hook scripts inside /usr/local/share/githooks!"
    echo
    echo "Please make sure you have made a backup of any scripts in this directory"
    echo "you would like to keep and then delete them so that cleanup may continue."
    exit 1
  fi
}

repos() {
  find "${HOME}/go/src/github.com" -name ".git" -type d
  find "${HOME}/workspace" -name ".git" -type d
}

check_and_remove_project_local_hooks() {
  for repo in $(repos); do
    if [ -d "${repo}/hooks" ]; then
      for hook in ${repo}/hooks/*; do
        if [[ $hook =~ .sample$ ]]; then
          continue
        fi

        sha=$(shasum "${hook}" | cut -f1 -d' ')
        if [ "${sha}" = "ba388887197fb3c289258eb12d0743551c878201" ] || [ "${sha}" = "2725e8727e7afb311fe042780f21859e6b068c08" ] || [ "${sha}" = "f2b7b7578618d3ded08df1164437e7b8b8e3a736" ]; then
          delete "$hook"
        else
          echo "Found unexpected hook script: ${hook}!"
          echo
          echo "Please make sure you have made a backup of this script if you would"
          echo "like to keep it and then delete it so that cleanup may continue."

          exit 1
        fi
      done
    fi
  done
}

check_for_user_hooks() {
  if [ -d ${HOME}/.githooks ]; then
    echo "Found extra hook directory: ${HOME}/.githooks!"
    echo
    echo "Please make sure you have made a backup of any scripts in this directory"
    echo "you would like to keep and then delete them and the directory so that"
    echo "cleanup may continue."
    exit 1
  fi
}

check_for_project_hooks() {
  for repo in $(repos); do
    project=$(dirname "${repo}")

    if [ -d "${project}/githooks" ]; then
      echo "Found extra hook directory: ${project}/githooks!"
      echo
      echo "Please make sure you have made a backup of any scripts in this directory"
      echo "you would like to keep and then delete the directory so that cleanup may"
      echo "continue."
      exit 1
    fi
  done
}

main() {
  git config --global --unset init.templatedir
  git config --global --remove-section secrets
  git config --system --unset hooks.global

  uninstall_git_secrets
  uninstall_git_hooks
  remove_git_secrets_hook_file
  check_for_user_hooks
  check_for_project_hooks
  check_and_remove_project_local_hooks
}

usage() {
  echo "$0: remove an old git-hooks and git-secrets installation"
  echo "  -h: show this help"
  echo "  -n: dry-run (do not delete any files)"
}

while test $# -gt 0; do
  case "$1" in
    -h)
      usage
      exit 0
      ;;
    -d)
      shift
      export DRY_RUN=1
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

main
