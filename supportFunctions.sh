#!/bin/bash

#Function to determine whether it's daytime or nighttime based on location
#Param1: Location-code as string. Eg.: HUXX0017 is a code for Nagykanizsa, Hungary
#Param2: Time offset for the decision. Sunrise will be taken earlier, sunset later. Default value 1 hour. Format: hhmm
exitAtNightTime()
{
    local location=$1
    local offset=${2:-100}
    local tmpfile=/tmp/$location.out

    # Obtain sunrise and sunset raw data from weather.com
    wget -q "https://weather.com/weather/today/l/$location" -O "$tmpfile"

    local SUNR=$(grep SunriseSunset "$tmpfile" | grep -oE '((1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm]))' | head -1)
    local SUNS=$(grep SunriseSunset "$tmpfile" | grep -oE '((1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm]))' | tail -1)

    local sunrise=$(date --date="$SUNR" +%R)
    local sunset=$(date --date="$SUNS" +%R)

    # Use $sunrise and $sunset variables to fit your needs. Example:
    echo "Sunrise for location $location: $sunrise"
    echo "Sunset for location $location: $sunset"

    local currentTime=$(date +%H%M)
    echo "Current time: $currentTime"
    echo "Offset used for the decision: $offset"
    # Checking whether sun is up, to avoid dark images. 1 hour offset is used.
    if [[ 10#$currentTime -lt $((10#${sunrise//:} - $offset)) || 10#$currentTime -gt $((10#${sunset//:} + $offset)) ]];
    then
        echo 'It is night. Exiting...'
        exit 0
    else
        echo 'It is daytime. Continue...'
    fi
}