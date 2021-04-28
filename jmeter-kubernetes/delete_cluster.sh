#!/usr/bin/env bash
#apply multiple Jmeter namespaces on an existing kuberntes cluster
#Started On January 23, 2018
set -x
working_dir=`pwd`

#Get namesapce variable
tenant=`awk '{print $NF}' $working_dir/tenant_export`

echo "INFO: delete $nodes Jmeter slave replicas and service"

kubectl delete -n $tenant -f $working_dir/jmeter_slaves_deploy.yaml

kubectl delete -n $tenant -f $working_dir/jmeter_slaves_svc.yaml

echo "INFO: Delete Jmeter Master"

kubectl delete -n $tenant -f $working_dir/jmeter_master_configmap.yaml

kubectl delete -n $tenant -f $working_dir/jmeter_master_deploy.yaml
