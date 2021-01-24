#!/bin/bash
source ./supportFunctions.sh

if [[ $(jq -r .createTimelapseOnlyDurinDayTime config.json) == "true" ]]
then
    locationCode=$(jq -r .locationCode config.json)
    exitAtNightTime $locationCode 100
fi

mkdir -p -v ./temporaryStorage/

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
        echo 'Saving image remotely at' $remoteHostUserName@$remoteHost/permanentTimelapseStorage
        resultOfUploading=$(raspistill -o - | ssh -i $remoteHostUserName $remoteHostUserName@$remoteHost 'cat > ~/permanentTimelapseStorage/$(date '+%Y-%m-%d-%H-%M-%S').jpg' 2>&1 >/dev/null) 
        echo $resultOfUploading
        if [[ $resultOfUploading ]]
        then
            fileName=./temporaryStorage/$(date '+%Y-%m-%d-%H-%M-%S').jpg
            echo 'Saving image to remote host was not successful. Saving it locally at' $fileName
            raspistill -o $fileName
        fi
        echo 'Finished. Exiting...'
        exit 0 
    fi
fi
