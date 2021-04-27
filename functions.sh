#!/bin/bash

function group {
  if [ -n "${GITHUB_ACTIONS}" ]; then
    echo -n "::group::"
  fi
  echo -e $1
}

function endgroup {
  if [ -n "${GITHUB_ACTIONS}" ]; then
    echo "::endgroup::"
  fi
}

function log {
  echo -e "\033[0;33m$*\033[0m"
}

function error {
  echo -e "\033[0;31m$*\033[0m"
}

function success {
  MSG=$1
  echo -e "\033[0;32m${MSG}\033[0m"
}

function run_with_check {
  (
    MSG=$1
    shift
    set +e
    (
      $* >/tmp/run.log 2>/tmp/run.log
    )
    RESULT=$?
    set -e
    if [ "${RESULT}" -eq 0 ]; then
      group "\033[0;32m✅ ${MSG}\033[0m"
    else
      group "\033[0;31m❌ ${MSG}\033[0m"
    fi
    cat /tmp/run.log
    endgroup
    return $RESULT
  )
}

