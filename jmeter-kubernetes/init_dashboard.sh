#!/usr/bin/env bash
set -xe
working_dir=`pwd`

#Get namesapce variable
tenant=`awk '{print $NF}' $working_dir/tenant_export`

## Create jmeter database automatically in Influxdb

echo "INFO: Creating Influxdb jmeter Database"

##Wait until Influxdb Deployment is up and running
##influxdb_status=`kubectl get po -n $tenant | grep influxdb-jmeter | awk '{print $2}' | grep Running

influxdb_pod=`kubectl get po -n $tenant | grep influxdb-jmeter | awk '{print $1}'`
kubectl exec -ti -n $tenant $influxdb_pod -- influx -execute 'CREATE DATABASE jmeterdb'

## Create the influxdb datasource in Grafana



## Make load test script in Jmeter master pod executable

echo "INFO: Get Master pod details"
master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`
#kubectl exec -ti -n $tenant $master_pod -- cp -r /load_test /jmeter/load_test
#kubectl exec -ti -n $tenant $master_pod -- chmod 755 /jmeter/load_test

##kubectl cp $working_dir/influxdb-jmeter-datasource.json -n $tenant $grafana_pod:/influxdb-jmeter-datasource.json

echo "INFO: Creating the grafana datasource"
grafana_pod=`kubectl get po -n $tenant | grep jmeter-grafana | awk '{print $1}'`
echo "INFO: Add infludb datasource:"
kubectl exec -ti -n $tenant $master_pod -- curl 'http://admin:admin@jmeter-grafana:3000/api/datasources' -X POST -H 'Content-Type: application/json;charset=UTF-8' --data-binary '{"name":"jmeterdb","type":"influxdb","url":"http://jmeter-influxdb:8086","access":"proxy","isDefault":false,"database":"jmeterdb","user":"admin","password":"admin"}'

echo "INFO: GET DATASOURCES:"
kubectl exec -ti -n $tenant $master_pod -- curl 'http://admin:admin@jmeter-grafana:3000/api/datasources' -X GET

echo "INFO: Get connection to grafana by using port forwarding:"
echo "while true; do kubectl --namespace jmeter port-forward service/jmeter-grafana 3000:3000; done"