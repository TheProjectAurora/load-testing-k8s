#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod.
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.
#set -x
working_dir="`pwd`"

#Get namesapce variable
tenant=`awk '{print $NF}' "$working_dir/tenant_export"`

#Get Master pod details
master_pod=`kubectl get po -n $tenant | grep jmeter-master | awk '{print $1}'`

echo "INFO: Generate HTML file from results"
kubectl exec -ti -n $tenant $master_pod -- /bin/bash -c "rm -Rf /tmp/html && mkdir -pv /tmp/html && /jmeter/apache-jmeter-*/bin/jmeter -g /tmp/*.csv -e -o /tmp/html"
RESULTTIME=$(date +%Y%m%dT%H%M%S)
echo "INFO: Copy $master_pod:/tmp/ results to:./results-R${RESULTTIME}"
mkdir -v ./results-R${RESULTTIME}
kubectl cp -n $tenant $master_pod:/tmp/ ./results-R${RESULTTIME}/.


echo "Execution output in ./results-R${RESULTTIME}/ folder"