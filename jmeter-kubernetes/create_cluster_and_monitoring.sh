#!/usr/bin/env bash
#apply multiple Jmeter namespaces on an existing kuberntes cluster
#Started On January 23, 2018
#set -x
working_dir=`pwd`

echo "INFO: checking if kubectl is present"

if ! hash kubectl 2>/dev/null
then
    echo "INFO: 'kubectl' was not found in PATH"
    echo "INFO: Kindly ensure that you can acces an existing kubernetes cluster via kubectl"
    exit
fi

kubectl version --short

echo "INFO: Current list of namespaces on the kubernetes cluster:"

echo

kubectl get namespaces | grep -v NAME | awk '{print $1}'

echo

tenant="$1"
if [ -z "$tenant" ]
then
  echo "INFO: Enter the name of the new tenant unique name, this will be used to apply the namespace"
  read tenant
fi

echo

#Check If namespace exists

kubectl get namespace $tenant > /dev/null 2>&1
if [ $? -eq 0 ]
then
  echo "INFO: Namespace $tenant already exists"
  echo "INFO: Current list of namespaces on the kubernetes cluster"
  sleep 2

  kubectl get namespaces | grep -v NAME | awk '{print $1}'
  echo "INFO: DO YOU WANNA CONTINUE? Y/n?"
  read continue
  if [ "${continue}" != "Y" ]
  then
    exit 1
  fi
fi

echo

kubectl get namespace $tenant > /dev/null 2>&1
if [ $? -gt 0 ]
then
  echo "INFO: Creating Namespace: $tenant"
  kubectl create namespace $tenant
  echo "INFO: Namspace $tenant has been applyd"
fi 

echo

echo "INFO: Creating Jmeter slave nodes"

nodes=`kubectl get no | egrep -v "master|NAME" | wc -l`

echo

echo "INFO: Number of worker nodes on this cluster is " $nodes

echo "INFO: Creating $nodes Jmeter slave replicas and service"

echo

kubectl apply -n $tenant -f $working_dir/jmeter_slaves_deploy.yaml

kubectl apply -n $tenant -f $working_dir/jmeter_slaves_svc.yaml

echo "INFO: Creating Jmeter Master"

kubectl apply -n $tenant -f $working_dir/jmeter_master_configmap.yaml

kubectl apply -n $tenant -f $working_dir/jmeter_master_deploy.yaml


echo "INFO: Creating Influxdb and the service"

kubectl apply -n $tenant -f $working_dir/jmeter_influxdb_configmap.yaml

kubectl apply -n $tenant -f $working_dir/jmeter_influxdb_svc.yaml

kubectl apply -n $tenant -f $working_dir/jmeter_influxdb_statefull.yaml

echo "INFO: Creating Grafana Deployment"

kubectl apply -n $tenant -f $working_dir/jmeter_grafana_statefull.yaml

kubectl apply -n $tenant -f $working_dir/jmeter_grafana_svc.yaml

echo "INFO: Printout Of the $tenant Objects"

echo

kubectl get -n $tenant all

echo namespace = $tenant > $working_dir/tenant_export
