#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.
#set -x
working_dir="`pwd`"

#Get namesapce variable
tenant=`awk '{print $NF}' "$working_dir/tenant_export"`

mode="$1"
shift
[ -n "$mode" ] || read -p 'First parameter execution mode have to be master|cluster ' mode
echo "INFO MODE:${mode}"
if [ "$mode" != "master" ] && [ "$mode" != "cluster" ] 
then
    echo "First parameter have to be master|cluster"
    exit
fi

jmx="$1"
shift
[ -n "$jmx" ] || read -p 'Enter path to the jmx file ' jmx

host="$1"
shift
output="$1"
shift
[ -n "$host" ] || read -p 'Give hostname ' host

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

test_name="$(basename "$jmx")"

#Get slave pods:
slave_pods=`kubectl get po -n jmeter | egrep "jmeter-master|jmeter-slave" | awk '{print $1}'`
#Get Master pod details
master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`
# Copy image to nodes:
for file in ./testdata/*
do
    for pod in $slave_pods $master_pod
    do 
        echo "INFO: Copy ${file} to ${pod}:/."
        kubectl cp "${file}" -n $tenant "${pod}:/."
    done
done

#Copy test to master
echo "INFO: Copy "$jmx" to $master_pod:/$test_name"
kubectl cp "$jmx" -n $tenant "$master_pod:/$test_name"

echo "INFO: Starting Jmeter load test in mode:$mode"
if [ "$mode" == "cluster" ]
then
    prefix='G'
elif [ "$mode" == "master" ]
then
    prefix='J'
fi

STARTTIME=$(date +%Y%m%dT%H%M%S)
kubectl exec -n $tenant $master_pod -- /bin/bash /load_test/load_test $mode -n -p /load_test/full-logs.properties -t /$test_name -${prefix}BASE_URL=$host -l /tmp/${output}  $@
