#!/bin/bash

cd ../permanentTimelapseStorage && ffmpeg -y -framerate 10 -pattern_type glob -i '*.jpg' -c:v libx264 -s 800x600 out.mp4
