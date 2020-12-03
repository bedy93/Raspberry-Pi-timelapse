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
echo 'TemporaryStorage size:' $directorySize
echo 'Directory deletion threshold :' $tempStorageDeletionSizeLimitInMB

if [ $tempStorageDeletionSizeLimitInMB -gt $directorySize ]
then
    echo 'Temp directory did not reach given size. Exiting'
    exit 0
fi

echo 'Saving everythin before deletion...'
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
fi

echo '...checking whether everything was saved' 
onlyInTemporaryDir=$(diff -r ./temporaryStorage/ $permanentLocalStorage | grep 'Only in ./temporaryStorage/:')
echo $onlyInTemporaryDir
if [[ -z $onlyInTemporaryDir ]]
then
    echo 'Everything was saved. Deleting ./temporaryStorage'
else
    echo 'Somthing cannot be saved. Exiting...'
fi