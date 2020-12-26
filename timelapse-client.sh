#!/bin/bash

mkdir -p -v ./temporaryStorage/

fileName=./temporaryStorage/$(date '+%Y-%m-%d-%H-%M-%S').jpg

echo 'Saving picture at' $fileName 
touch $fileName

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
    fi
elif [[ $(jq -r .useRemoteHost config.json) == "true" ]]
then
    remoteHost=$(jq -r .remoteHost config.json)
    if [[ $remoteHost == "null" ]]
    then
        echo 'You need to define remoteHost in config.json. Exiting...'
        exit 1
    else
        echo 'Copying files from ./temporaryStorage/ to ' $remoteHost
    fi
fi