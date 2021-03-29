#!/bin/bash -e

docker build --tag="kubernautslabs/jmeter_base:latest" -f Dockerfile-base .
docker build --tag="kubernautslabs/jmeter_master:latest" -f Dockerfile-master .
docker build --tag="kubernautslabs/jmeter_slave:latest" -f Dockerfile-slave .
docker build --tag="kubernautslabs/jmeter_reporter" -f Dockerfile-reporter .
