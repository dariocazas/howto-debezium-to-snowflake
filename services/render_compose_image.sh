#!/bin/bash
#
# This script update the PNG with the services of the docker-compose.yml 
# Is based on https://github.com/pmsipilot/docker-compose-viz

docker run --rm -it --name dcv -v $(pwd):/input pmsipilot/docker-compose-viz render -m image docker-compose.yml --force
