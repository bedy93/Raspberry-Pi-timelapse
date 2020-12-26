#!/bin/bash

cd ../permanentTimelapseStorage && ffmpeg -y -framerate 10 -pattern_type glob -i '*.jpg' -c:v libx264 out.mp4
