#!/usr/bin/env bash
source $DOT_ROOT/constants.sh
DOT_MODULE="archinstall"

# Username
while [ "$username" == "" ] || [ "$username" == "root" ]; do
    log ask "Username: "
    read username
done

# Password
while [ "$password" == "" ] || [ "$password" != "$passwordConfirm" ]; do
    [ "$password" != "$passwordConfirm" ] \
        && log tell "Passwords do not match"
    log ask "Login Password: "
    read -s password
    echo
    log ask "Login Password (confirm): "
    read -s passwordConfirm
    echo
done
passwordConfirm=

# Disk Password
while [ "$diskPassword" == "" ] || [ "$diskPassword" != "$diskPasswordConfirm" ]; do
    [ "$diskPassword" != "$diskPasswordConfirm" ] \
        && log tell "Passwords do not match"
    log ask "Disk Password: "
    read -s diskPassword
    echo
    log ask "Disk Password (confirm): "
    read -s diskPasswordConfirm
    echo
done

# Hostname
if [ "$host" == "" ]; then
    failHostname="adryd-machine-$RANDOM"
    log ask "Hostname [$failHostname]: "
    read host
    [ "$host" == "" ] && host="$failHostname"
fi
failHostName=

# Installation Target
while [ ! -e "$installTargetDev" ]; do
    [ ! -e "$installTargetDev" ] && [ "$installTargetDev" != "" ] && log tell "Invalid block device"
    [ "$installTargetDev" == "l" ] && lsblk | less
    log ask "Target disk (l for a list): "
    read installTargetDev
done

installTargetUUID=`lsblk -l $installTargetDev -o PATH,UUID | grep "$installTargetDev" | grep -oP "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"`

[ "$timezone" == "" ] && timezone="America/New_York"
[ "$language" == "" ] && language="en_US.UTF-8"
[ "$keymap" == "" ] && keymap="us"
[ "$basePackages" == "" ] && basePackages=("linux" "linux-firmware" "linux-headers" "base" "base-devel" "man-db" "man-pages" "btrfs-progs"
    "efibootmgr" "networkmanager" "neovim" "git" "fish")

log silly "Calling partitioning script"
installTargetDev=$installTargetDev host=$host diskPassword=$diskPassword \
    $DOT_ROOT/modules/arch/arch-install/partition.sh

function ucodepkg() {
    cpuType=`cat /proc/cpuinfo | grep vendor_id | sed "s/vendor_id\t: //g" | head -1`
    [ "$cpuType" == "GenuineIntel" ] && printf "intel-ucode"
    [ "$cpuType" == "AuthenticAmd" ] && printf "amd-ucode"
}
log silly "Detecting CPU for microcode package"
basePackages+=(`ucodepkg`)

log info "Installing base system"
pacstrap /mnt ${basePackages[*]}
log info "Writing fstab"
genfstab /mnt -U >> /mnt/etc/fstab
log info "Copying over .adryd"
cp -r $DOT_ROOT /mnt$DOT_ROOT

rootUUID=`lsblk -o UUID,PARTLABEL | grep "$host" | grep -oP "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"`
username=$username password=$password host=$host timezone=$timezone language=$language keymap=$keymap rootUUID=$rootUUID ucode=`ucodepkg`\
    arch-chroot /mnt bash $DOT_ROOT/systems/personal/arch-install/configure.sh

passsword=

# Remove coppied dotfiles
# log silly "Remove coppied dotfiles"
# rm -rf /mnt/$DOT_ROOT
# log silly "Placing install script in new home folder"
# cp $DOT_ROOT/download.sh /mnt/home/$username/install.sh
