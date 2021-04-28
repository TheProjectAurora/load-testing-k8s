#!/bin/bash -e
# JMETER STUFF
set -xe
docker build --tag="theprojectaurora/jmeter_cluster:latest" -f infra/jmeter/Dockerfile .
jmeter_cluster_ID=$(docker image list --format '{{.ID}}' theprojectaurora/jmeter_cluster:latest)
docker tag theprojectaurora/jmeter_cluster:latest theprojectaurora/jmeter_cluster:${jmeter_cluster_ID}
#docker push theprojectaurora/jmeter_cluster:latest
#docker push theprojectaurora/jmeter_cluster:${jmeter_cluster_ID}

# GRAFANA REPORTER STUFF
#docker build --tag="jmeter_reporter:latest" -f Dockerfile-reporter .
