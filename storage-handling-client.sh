#!/bin/bash

if [ ! -d "./temporaryStorage" ]
then
    echo 'temporaryStorage does not exist. Exiting'
    exit 1
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
        echo 'Finished.'
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
        echo 'Finished. Exiting...'
        exit 0
    else
        echo 'Something cannot be saved locally. Exiting...'
        exit 1
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
            echo 'Finished. Exiting...'
            exit 0
        else
            echo 'Something cannot be saved remotely. Exiting...'
            exit 1
	fi
    fi
fi
