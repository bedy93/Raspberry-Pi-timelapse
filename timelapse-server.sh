#!/bin/bash
source ./supportFunctions.sh

exitAtNightTime "HUXX0017" 100

cd ../permanentTimelapseStorage && ffmpeg -y -framerate 10 -pattern_type glob -i '*.jpg' -c:v libx264 -s 800x600 out.mp4
