#!/bin/bash
source ./supportFunctions.sh

exitAtNightTime "HUXX0017" 100

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
