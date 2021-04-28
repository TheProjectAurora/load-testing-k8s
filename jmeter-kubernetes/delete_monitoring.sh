#!/usr/bin/env bash
#apply multiple Jmeter namespaces on an existing kuberntes cluster
#Started On January 23, 2018
set -x
working_dir=`pwd`

#Get namesapce variable
tenant=`awk '{print $NF}' $working_dir/tenant_export`

echo "INFO: Delete Influxdb and the service"

kubectl delete -n $tenant -f $working_dir/jmeter_influxdb_configmap.yaml

kubectl delete -n $tenant -f $working_dir/jmeter_influxdb_svc.yaml

kubectl delete -n $tenant -f $working_dir/jmeter_influxdb_statefull.yaml

echo "INFO: Delete Grafana Deployment"

kubectl delete -n $tenant -f $working_dir/jmeter_grafana_statefull.yaml

kubectl delete -n $tenant -f $working_dir/jmeter_grafana_svc.yaml

echo "INFO: If you wanna delete InfluxDB and Grafana persisten data then easy way is delete whole $tenant namespace"
