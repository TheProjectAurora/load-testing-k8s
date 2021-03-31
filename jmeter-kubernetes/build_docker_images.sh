#!/bin/bash -e

docker build --tag="jmeter_cluster:latest" -f Dockerfile .
docker build --tag="jmeter_reporter:latest" -f Dockerfile-reporter .
