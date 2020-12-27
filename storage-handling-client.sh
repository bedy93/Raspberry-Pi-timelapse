#!/bin/bash

tempStorageDeletionSizeLimitInMB=$(jq -r .tempStorageDeletionSizeLimitInMB config.json)
if [[ $tempStorageDeletionSizeLimitInMB == "null" ]]
then
    echo 'You need to define tempStorageDeletionSizeLimitInMB in config.json. Exiting...'
    exit 1
fi

if [ ! -d "./temporaryStorage" ]
then
    echo 'temporaryStorage does not exist. Exiting'
    exit 1
fi

echo 'Cheking size of ./temporaryStorage'
directorySize=$(du -s ./temporaryStorage | grep -o '[0-9]\+')
directorySize=$(expr $directorySize / 1000)
echo 'TemporaryStorage size:' $directorySize 'MB'
echo 'Directory deletion threshold :' $tempStorageDeletionSizeLimitInMB 'MB'

if [ $tempStorageDeletionSizeLimitInMB -gt $directorySize ]
then
    echo 'Temp directory did not reach given size. Exiting'
    exit 0
fi

echo 'Saving everything before deletion...'
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
    remoteHostUserName=$(jq -r .remoteHostUserName config.json)
    if [[ $remoteHost == "null" ]] || [[ $remoteHostUserName == "null" ]]
    then
        echo 'You need to define remoteHost and remoteHostUserName in config.json. Exiting...'
        exit 1
    else
        echo 'Copying files from ./temporaryStorage/ to ' $remoteHostUserName@$remoteHost/permanentTimelapseStorage
        $(rsync -a -e "ssh -i $remoteHostUserName" ./temporaryStorage/ $remoteHostUserName@$remoteHost:permanentTimelapseStorage)
    fi
fi

echo '...checking whether everything was saved'
if [[ $(jq -r .useRemoteHost config.json) == "false" ]]
then
    onlyInTemporaryDir=$(diff -r ./temporaryStorage/ $permanentLocalStorage | grep 'Only in ./temporaryStorage/:')
    if [[ -z $onlyInTemporaryDir ]]
    then
        echo 'Everything was saved locally. Deleting ./temporaryStorage'
        rm -r ./temporaryStorage
    else
        echo 'Somthing cannot be saved locally. Exiting...'
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
        onlyInTemporaryDir=$(rsync -a -e "ssh -i $remoteHostUserName" -rin ./temporaryStorage/ $remoteHostUserName@$remoteHost:permanentTimelapseStorage)
        if [[ -z $onlyInTemporaryDir ]]
        then
            echo 'Everything was saved remotely. Deleting ./temporaryStorage'
            rm -r ./temporaryStorage
        else
            echo 'Somthing cannot be saved remotely. Exiting...'
        fi
    fi
fi