#!/bin/bash

# Insert your location. For example HUXX0017 is a location code for Nagykanizsa, Hungary
location="HUXX0017"
tmpfile=/tmp/$location.out

# Obtain sunrise and sunset raw data from weather.com
wget -q "https://weather.com/weather/today/l/$location" -O "$tmpfile"

SUNR=$(grep SunriseSunset "$tmpfile" | grep -oE '((1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm]))' | head -1)
SUNS=$(grep SunriseSunset "$tmpfile" | grep -oE '((1[0-2]|0?[1-9]):([0-5][0-9]) ?([AaPp][Mm]))' | tail -1)

sunrise=$(date --date="$SUNR" +%R)
sunset=$(date --date="$SUNS" +%R)

# Use $sunrise and $sunset variables to fit your needs. Example:
echo "Sunrise for location $location: $sunrise"
echo "Sunset for location $location: $sunset"

currentTime=$(date +%H%M)
echo "Current time: $currentTime"
# Checking whether sun is up, to avoid dark images. 1 hour offset is used.
if [[ 10#$currentTime -lt $((10#${sunrise//:} - 100)) || 10#$currentTime -gt $((10#${sunset//:} + 100)) ]];
then
    echo 'It is night. Exiting...'
    exit 0
fi

mkdir -p -v ./temporaryStorage/

fileName=./temporaryStorage/$(date '+%Y-%m-%d-%H-%M-%S').jpg

echo 'Saving picture at' $fileName
raspistill -o $fileName

if [[ $(jq -r .useRemoteHost config.json) == "false" ]]
then
    permanentLocalStorage=$(jq -r .permanentLocalStorage config.json)
    if [[ $permanentLocalStorage == "null" ]]
    then
        echo 'You need to define permanentLocalStorage in config.json. Exiting...'
        exit 1
    else
        mkdir -p -v $permanentLocalStorage
        echo 'Copying files from ./temporaryStorage/ to ' $permanentLocalStorage
        cp -a ./temporaryStorage/. $permanentLocalStorage
        echo 'Finished. Exiting...'
        exit 0
    fi
elif [[ $(jq -r .useRemoteHost config.json) == "true" ]]
then
    remoteHost=$(jq -r .remoteHost config.json)
    remoteHostUserName=$(jq -r .remoteHostUserName config.json)
    if [[ $remoteHost == "null" ]] || [[ $remoteHostUserName == "null" ]]
    then
        echo 'You need to define remoteHost and remoteHostUserName in config.json. Exiting...'
        exit 1
    else
        echo 'Copying files from ./temporaryStorage/ to ' $remoteHostUserName@$remoteHost/permanentTimelapseStorage
        $(rsync -a -e "ssh -i $remoteHostUserName" ./temporaryStorage/ $remoteHostUserName@$remoteHost:permanentTimelapseStorage)
        echo 'Finished. Exiting...'
        exit 0 
    fi
fi
