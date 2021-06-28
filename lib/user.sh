#!/bin/bash
function get_user() {
  export USERNAME=$(whoami)
  if [ "$USERNAME" = "jane" ]; then
    export PERSONAL="yes"
  else
    export PERSONAL="no"
  fi
}
get_user
