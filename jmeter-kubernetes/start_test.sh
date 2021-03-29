#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.
set -xe

working_dir="`pwd`"

#Get namesapce variable
tenant=`awk '{print $NF}' "$working_dir/tenant_export"`

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

#Get Master pod details

master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`

kubectl cp "$jmx" -n $tenant "$master_pod:/$test_name"

## Echo Starting Jmeter load test

kubectl exec -ti -n $tenant $master_pod -- /bin/bash /load_test/load_test -n -p /load_test/full-logs.properties -t /$test_name -JBASE_URL=$host -l /tmp/${output} $@ -Dserver.rmi.ssl.disable=true
kubectl cp -n $tenant "$master_pod:/tmp/${output}" ${output}
echo "Execution output:${output} execute:"
echo "cat ${output}"