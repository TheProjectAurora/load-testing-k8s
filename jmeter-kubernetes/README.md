# Jmeter Cluster Support for Kubernetes and OpenShift

## Prerequisits
Kubernetes > 1.16
Docker
Minikube

## SandBox - Start minikube and connect kubectl and docker to it:
```
minikube start --cpus=4 --memory=4g
minikube kubectl config view > ~/.kube/config

export DOCKER_TLS_VERIFY=1 DOCKER_HOST=tcp://$(docker container port minikube 2376) export DOCKER_CERT_PATH=/mnt/c/Users/sakar/.minikube/certs;
```

## Taint nodes where jmeter should be executed
### FYI: Taints with multible nodes could be tested with https://kind.sigs.k8s.io/
Taint the nodes where you wanna jmeter to under execution:
```bash
kubectl get nodes
kubectl taint node <NODE_NAME> perf=true:NoSchedule
```
## Start SUT (just nginx)
```
kubectl --namespace default create deployment nginx --image=nginx
kubectl --namespace default create service nodeport nginx --tcp=80:80
kubectl --namespace default get pods
```
If nginx pod is in Pending state then:

With ```kubectl --namespace default edit deployment nginx``` add toleration in place:
```
---clip here you see that tolerations chould be in same level than containers---
  containers:
---clip---
  tolerations:
  - effect: NoSchedule
    key: perf
    operator: Exists
---clap---

```
Then nginx should be in running state: ```kubectl --namespace default get pods```

## Jmeter environment startup:
Note. Without perf=true:NoSchedule node taint jmeter could not be started
Start jmeter tools:
```bash
./build_docker_images.sh
./cluster_create.sh
./dashboard_init.sh
kubectl --namespace jmeter port-forward service/jmeter-grafana 3000:3000 &
```
http://localhost:3000/ should answer
Import Dashboard: GrafanaJMeterTemplate.json
```
./start_test.sh test_nginx.jmx nginx.default jmeter_results.csv
```

## Delete all:
```bash
kubectl --namespace default delete deployment nginx
kubectl --namespace default delete service nginx
kubecl delete namespace <same_that_you_give_to_cluster_create.sh>
unset DOCKER_TLS_VERIFY DOCKER_HOST DOCKER_CERT_PATH
minikube delete
```

# Based to
Please follow the guide "Load Testing Jmeter On Kubernetes" on our medium blog post:
https://github.com/kubernauts/jmeter-kubernetes
https://github.com/kubernauts/jmeter-operator
https://blog.kubernauts.io/load-testing-as-a-service-with-jmeter-on-kubernetes-fc5288bb0c8b

# LTaaS With SSL Enabled (Not tested yet)
The major part is to generate the certificate, this needs to be done before building the docker images of the
master and slave.
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
