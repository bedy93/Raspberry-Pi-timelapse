#!/bin/bash

resolution=$(jq -r .timelapseVideoResolution config.json)

cd ../permanentTimelapseStorage && ffmpeg -y -framerate 10 -pattern_type glob -i '*.jpg' -c:v libx264 -s $resolution out.mp4

