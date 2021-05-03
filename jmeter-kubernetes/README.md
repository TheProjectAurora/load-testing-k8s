# Jmeter Cluster Support for Kubernetes

## Prerequisits
6G Memory
<br>Kubernetes > 1.16
<br>Docker
<br>Kind - https://kind.sigs.k8s.io/

## SandBox - Start kind cluster and connect kubectl to it:
```
kind create cluster --config kind_cluster.yaml
```

## Taint an label nodes where jmeter should be executed
Taint the node(s) where you wanna jmeter to under execution:
```bash
kubectl get nodes
kubectl taint node kind-worker2 perf=true:NoSchedule
kubectl label node kind-worker2 perf="true"
```

## Jmeter environment startup:
Start jmeter tools (recommend to use jmeter namespace):
1. Create jmeter clustes: ```./create_cluster_and_monitoring.sh```
1. Then pods should be in running state: ```kubectl get pods -n jmeter```
1. Initialize influxdb and add it datasource to grafana: ```./init_dashboard.sh```

## Start SUT (just nginx)
```
kubectl create namespace suteg
kubectl --namespace suteg create deployment nginx --image=nginx
kubectl --namespace suteg create service clusterip nginx --tcp=80:80
```
Then nginx should be in running state: ```kubectl --namespace suteg get pods```

## START TEST IN K8S:
start_test.sh made needed preparation to system and in the end start jmeter to backround with nohub to jmeter-master pod. That how execution could be leaved to runing without requirement to keep computer running where start_test.sh script is executed. This also avoid network glitch interupts to execution. Test execution happened inside of test environment. 
<br>
Sut address is: http://nginx.suteg:80
### Execute jmeter in cluster mode:
```
./start_test.sh cluster test_nginx.jmx http://nginx.suteg:80 jmeter_results.csv -GTHREADS=20 -GRAMP_UP_MIN=2 -GHOLD_TARGET_MIN=0 -GDEVIATION=50 -GCONSTANT_DELAY=100 -GSETUP_THREADS=10 -GSETUP_RAMP_UP_SEC=60
```
### Execute jmeter in master mode: 
```
./start_test.sh master test_nginx.jmx http://nginx.suteg:80 jmeter_results.csv -JTHREADS=20 -JRAMP_UP_MIN=2 -JHOLD_TARGET_MIN=0 -JDEVIATION=50 -JCONSTANT_DELAY=100 -JSETUP_THREADS=10 -JSETUP_RAMP_UP_SEC=60
```

## MONITOR/RESULTS OF JMETER EXECUTION IN K8S:
### Check is jmeter execution under execution in jmeter-master pod
```
kubectl exec -it -n jmeter $(kubectl get -n jmeter pods | grep -w jmeter-master.*) -- bash -c "ps aux | grep jmeter | grep -v grep"
```
### Follow jmeter-master execution in pod
```
kubectl exec -it -n jmeter $(kubectl get -n jmeter pods | grep -w jmeter-master.*) -- bash -c "tail -f /tmp/execution.txt"
```
## GET RESULTS OF JMETER IN K8S WHEN TESTS ARE EXECUTED:
```
./get_results.sh
```
### Load execution results in influxdb with grafana:
```bash
while true; do kubectl --namespace jmeter port-forward service/jmeter-grafana 3000:3000; done
```
- http://localhost:3000/ should answer <br>
- Import Dashboard from [./dashboard folder](./dashboard folder) <br>
  - By default JustJmeterGraph.json work smoothly
  - If you install https://k8slens.dev/ connect it to cluster and under cluster setting install "Metrics Stack" you can use Jmeter+LensK8sPrometheus-metrics.json 
- Jmeter accurate results are in:
    - jmeter_results.csv file
    - html/index.html file



## JMETER IN OWN DESKTOP (R&D of testcases):
### With working version of /.kube/config mount to noVNC:
```
while true; do kubectl --namespace suteg port-forward service/nginx 80:80; done
jmeter -n -t test_nginx.jmx -JBASE_URL=http://localhost:80 -l jmeter_results.csv -JTHREADS=10 -JRAMP_UP_MIN=1 -JHOLD_TARGET_MIN=0 -JDEVIATION=50 -JCONSTANT_DELAY=100 -JSETUP_THREADS=10 -JSETUP_RAMP_UP_SEC=60
```
### Against nginx.suteg that is kicked up in docker-compose.yaml
```
jmeter -n -t test_nginx.jmx -JBASE_URL=http://nginx.sut:80 -l jmeter_results.csv -JTHREADS=10 -JRAMP_UP_MIN=1 -JHOLD_TARGET_MIN=0 -JDEVIATION=50 -JCONSTANT_DELAY=100 -JSETUP_THREADS=10 -JSETUP_RAMP_UP_SEC=60
```

# CLEANING OF ENV:
## If you wanna keep influxdb and grafana persistent data:
```bash
./delete_cluster.sh
./delete_monitoring.sh
```
FYI: Redeploy all stuff that not exist:
```bash
./create_cluster_and_monitoring.sh
./init_dashboard.sh
```
## IF YOU WANNA CLEAN ALSO InfluxDB ang Grafana peristent data:
```bash
kubectl delete namespace suteg
kubectl delete namespace <same_that_you_give_to_cluster_create.sh>
e.g. kubectl delete namespace jmeter
```
Untaint nodes with command:
```bash
kubectl taint node <NODE_NAME> perf=true:NoSchedule-
kubectl label node <NODE_NAME> perf-
```
## SandBox - kind cluster clean:
```
kind delete cluster
```

# noVNC platform as a tool:
- include jmeter GUI
- kubectl work ok if it can get your ~/.kube volume mounted to container
- include 
    - python
    - Microsoft Visual Studio
    - browsers
    
<br><br>Read these before usage - Known Problems / features: https://github.com/TheProjectAurora/novnc-robotframework-docker#known-problems-existing-features
## Usage:
1. Execute: ```docker-compose up```
1. Go to: https://localhost user:coder pw:coderpw
1. Put it to fullscreen and start to play with it.
### Clean:
1. Execute: ```docker-compose down```

# Based to
Please follow the guide "Load Testing Jmeter On Kubernetes" on our medium blog post: <br>
https://github.com/kubernauts/jmeter-kubernetes <br>
https://github.com/kubernauts/jmeter-operator <br>
https://blog.kubernauts.io/load-testing-as-a-service-with-jmeter-on-kubernetes-fc5288bb0c8b

# LTaaS With SSL Enabled (Not tested yet)
The major part is to generate the certificate, this needs to be done before building the docker images of the
master and slave. <br>
To generate the certificate, download the jmeter archive and execute the script:
```
$ kubectl -n jmeter exec -ti jmeter-master-7b4bbb5b7d-tlmm2 bash -- create-rmi-keystore.sh
What is your first and last name?
[Unknown]: rmi
What is the name of your organizational unit?
[Unknown]: My unit name
What is the name of your organization?
[Unknown]: My organisation name
What is the name of your City or Locality?
[Unknown]: Your City
What is the name of your State or Province?
[Unknown]: Your State
What is the two-letter country code for this unit?
[Unknown]: XY
Is CN=rmi, OU=My unit name, O=My organisation name, L=Your City, ST=Your State, C=XY
correct?
[no]: yes
Copy the generated rmi_keystore.jks to jmeter/bin folder or reference it in property
'server.rmi.ssl.keystore.file'
$ kubectl -n jmeter cp jmeter-master-7b4bbb5b7d-tlmm2:rmi_keystore.jks .
```
The certificate file rmi_keystore.jks needs to be copied to the folder where the Dockerfile resides.
```
COPY rmi_keystore.jks /jmeter/apache-jmeter-$JMETER_VERSION/bin/
```
