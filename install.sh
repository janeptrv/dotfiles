#!/usr/bin/env bash

# set the root directory so we're not hardcoding paths
export DOT_ROOT=$(pwd)

source $DOT_ROOT/constants.sh
source $DOT_ROOT/lib/os.sh

# keep sudo alive
if [[ ! $EUID -eq 0 ]]; then
  log info "starting sudo"
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
fi

if [ "$DOT_OS" = "linux_fedora" ]; then
  log info "fedora install"
  for module in $DOT_ROOT/modules/fedora/**"$*"/install.sh; do
    . $module
  done
  for module in $DOT_ROOT/modules/common/**"$*"/install.sh; do
    . $module
  done
  if [ "$PERSONAL" = "yes" ]; then
    for module in $DOT_ROOT/modules/common/**"$*"/install.sh; do
      . $module
    done
  fi
elif [ "$DOT_OS" = "linux_arch" ]; then
  log info "arch install"
  if ["$USERNAME" = "root"] && ["$HOSTNAME" == "archiso"]; then
    $DOT_ROOT/modules/arch/arch-install/_install.sh
  elif [ "$1" = "dots" ]; then
    log info "installing only dots"
    dots=("bash" "fish" "git")
    for dot in ${dots[@]}; do
      for module in $DOT_ROOT/modules/common/**"$dot"/install.sh; do
        . $module
      done
    done
  else
    for module in $DOT_ROOT/modules/arch/**"$*"/install.sh; do
      . $module
    done
    for module in $DOT_ROOT/modules/common/**"$*"/install.sh; do
      . $module
    done
    if [ "$PERSONAL" = "yes" ]; then
      for module in $DOT_ROOT/modules/common/**"$*"/install.sh; do
        . $module
      done
    fi
  fi
fi

# unset DOT_SPLASH for future runs
unset DOT_SPASH
