#!/usr/bin/env bash

if [ -e "$(command -v git)" ]; then
  branches=("stable" "canary")

  git clone https://github.com/aurieh/dvm.sh
  cd dvm.sh
  ./dvm.sh update_path

  for branch in "${branches[@]}"; do
    $HOME/.dvm/sym/dvm install $BRANCH
  done
  $HOME/.dvm/sym/dvm default stable
fi
