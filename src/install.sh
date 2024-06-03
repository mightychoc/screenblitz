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

# Make binaries executable
log_info "Changing permissions of binaries"
chmod 755 /system/screenblitz/bin/*
chmod 755 /system/screenblitz/watcher.sh
chmod 755 /system/screenblitz/uninstall.sh

# Copy helper binaries to /system/bin
log_info "Moving helper binaries to /system/bin"
mv /system/screenblitz/bin/* /system/bin

# Remove the helper binaries from the SD-card
log_info "Removing helper binaries from screenblitz directory"
rm -r /system/screenblitz/bin

# Add the watcher script to the boot process
if [ -f /etc/mkshrc ]; then
    # Check if this line is in mkshrc
    if grep -q ": place customisations above this line" /etc/mkshrc; then
        log_info "Adding line to start watcher.sh to /etc/mkshrc"
        busybox sed -i "/: place customisations above this line/i \/system\/screenblitz\/watcher.sh" /etc/mkshrc
    else
        log_error "Could not find the marker line in /etc/mkshrc"
    fi
else
    log_error "Could not find file /etc/mkshrc"
fi

# Remounting file system as read-only
log_info "Remounting file system as read-only"
mount -o remount,ro /dev/block/mmcblk0p1 /system

echo -e "\n------------ SUMMARY ------------\n"

log_success "Finished installation of screenblitz."
log_info "Please check the details below and then restart the crab to start blitzing files."

if [ ! -f "/system/screenblitz/.env" ]; then
    log_error "No .env file found in /system/screenblitz/"
    exit 1
fi

source "/system/screenblitz/.env"
if [ -n "$GSOCKET_IP" ]; then
    log_info "GSOCKET_IP is set to ${GSOCKET_IP#*=}"
else
    log_warning "No GSOCKET_IP set in .env file - using the GSRN to blitz files"
fi

if [ -n "$TIMEOUT" ]; then
    log_info "TIMEOUT is set to ${TIMEOUT#*=}"
else
    log_warning "No TIMEOUT set in .env file - using 30 seconds as blitz interval"
fi

if [ -n "$SECRET" ]; then
    log_info "SECRET is set to ${SECRET#*=}"
else
    log_warning "No SECRET set in .env file - using 'screenblitz' as default secret"
fi
