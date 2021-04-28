#!/bin/bash -e
# JMETER STUFF
set -xe
docker build --tag="jmeter_cluster:latest" -f infra/jmeter/Dockerfile .
jmeter_cluster_ID=$(docker image list --format '{{.ID}}' jmeter_cluster:latest)
docker tag jmeter_cluster:latest jmeter_cluster:${jmeter_cluster_ID}
docker push jmeter_cluster:latest
docker push jmeter_cluster:${jmeter_cluster_ID}

# GRAFANA REPORTER STUFF
#docker build --tag="jmeter_reporter:latest" -f Dockerfile-reporter .
