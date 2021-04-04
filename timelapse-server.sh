#!/bin/bash

resolution=$(jq -r .timelapseVideoResolution config.json)

cd ../permanentTimelapseStorage
rm listOfVideos.txt

for dir in */     # list directories
do
    dir=${dir%*/}      # remove the trailing "/"
    if test -f "$dir/out.mp4";
    then
        echo "Video for $dir exists."
    else
        echo "Generating video $dir."
    	ffmpeg -y -framerate 10 -pattern_type glob -i $dir'/*.jpg' -c:v libx264 -s $resolution $dir/out.mp4
    fi
    echo "file '"$dir"/out.mp4'" >> listOfVideos.txt
done

ffmpeg -y -f concat -safe 0 -i listOfVideos.txt -c copy out.mp4 #Create the full video with concatenation
