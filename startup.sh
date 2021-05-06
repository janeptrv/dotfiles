#!/bin/bash
source $HOME/.adryd/constants.sh
source $AR_DIR/lib/os.sh
AR_MODULE="startup"

if [ "$AR_OS" == "linux_archlinux" ]; then
    if [ "$USER" == "root" ] && [ "$HOSTNAME" == "archiso" ]; then
        $AR_DIR/systems/personal/arch-install/_install.sh
    else
        [ "$USER" != "root" ] \
            && $AR_DIR/systems/personal/install.sh
    fi
fi