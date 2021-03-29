# Jmeter Cluster Support for Kubernetes and OpenShift

## Prerequisits
Kubernetes > 1.16
Docker
Minikube

# SandBox - Start minikube and connect kubectl and docker to it:
```
minikube start --cpus=4 --memory=4g
minikube kubectl config view > ~/.kube/config

export DOCKER_TLS_VERIFY=1 DOCKER_HOST=tcp://$(docker container port minikube 2376) export DOCKER_CERT_PATH=/mnt/c/Users/sakar/.minikube/certs;
```

## Execution

Taint the nodes where you wanna jmeter to under execution:
```bash
kubectl get nodes
kubectl taint nodes <NODE_NAME> perf=true:NoSchedule
```
Start jmeter tools:
```bash
./dockerimages.sh
./jmeter_cluster_create.sh
./dashboard.sh
kubectl --namespace jmeter port-forward service/jmeter-grafana 3000:3000 &
```
http://localhost:3000/ should answer
Import Dashboard: GrafanaJMeterTemplate.json
```
./start_test.sh
```

# Based to
Please follow the guide "Load Testing Jmeter On Kubernetes" on our medium blog post:
https://github.com/kubernauts/jmeter-kubernetes
https://github.com/kubernauts/jmeter-operator
https://blog.kubernauts.io/load-testing-as-a-service-with-jmeter-on-kubernetes-fc5288bb0c8b

