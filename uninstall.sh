#!/system/bin/sh

set -e

log_info() {
    echo -e "[INFO] - $1"
}

log_success() {
    echo -e "\e[32m[SUCCESS] - $1\e[0m"
}

log_warning() {
    echo -e "\e[93m[WARNING] - $1\e[0m"
}

log_error() {
   echo -e "\e[31m[ERROR] - $1\e[0m"
}

remove() {
    if [ -f "$1" ]; then
    log_info "Uninstalling $1"
    rm "$1"
    else
    log_warning "Binary $1 not found - please check manually if file was removed."
    SUCCESS=0
    fi
}

SUCCESS=1

# Mount the filesystem as read-write
log_info "Mounting /system as read-write"
mount -o remount,rw /dev/block/mmcblk0p1 /system

# Remove all helper binaries
remove /system/bin/bash 

remove /system/bin/gs_funcs

remove /system/bin/gs-netcat 

remove /system/bin/gsocket_dso.so.0 

remove /system/bin/gs-sftp 

remove /system/bin/blitz

remove /system/bin/gs-mount 

remove /system/bin/gsocket 

remove /system/bin/gsocket_uchroot_dso.so.0 

remove /system/bin/rsync

# Remove the autostart line from /etc/mkshrc
if [ -f /etc/mkshrc ]; then
    # Check if this line is in mkshrc
    if grep -q "\/system\/screenblitz\/watcher.sh" /etc/mkshrc; then
        log_info "Removing autostart line to from /etc/mkshrc"
        busybox sed -i "\/system\/screenblitz\/watcher.sh/d" "/etc/mkshrc"
    else
        log_warning "Could not find the autostart line to remove in /etc/mkshrc"
    fi
else
    log_error "Could not find file /etc/mkshrc"
fi

# Remove the screenblitz directory
if [ -d "/system/screenblitz"]; then
    log_info "Uninstalling screenblitz directory"
    rm -r /system/screenblitz
else
    log_warning "Could not find directory /system/screenblitz. Please check manually if folder was removed."
    SUCCESS=0
fi

# Mount the file system as read-only
log_info "Remounting /system as read-only"
mount -o remount,ro /dev/block/mmcblk0p1 /system

if [ $SUCCESS -eq 1 ]; then
    log_success "Successfully uninstalled screenblitz"
else
    log_error "A problem occured during uninstallation process. Please check the console log to locate the problem."
fi
