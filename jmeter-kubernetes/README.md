# Jmeter Cluster Support for Kubernetes and OpenShift

## Prerequisits
Kubernetes > 1.16
Docker
Minikube

# SandBox - Start minikube and connect kubectl and docker to it:
```
minikube start --cpus=4 --memory=4g
minikube kubectl config view > ~/.kube/config

export DOCKER_TLS_VERIFY=1;
export DOCKER_HOST=tcp://$(docker container port minikube 2376);
export DOCKER_CERT_PATH=/mnt/c/Users/sakar/.minikube/certs;
```

## Execution

```bash
./dockerimages.sh
./jmeter_cluster_create.sh
./dashboard.sh
./start_test.sh
```

# Based to
Please follow the guide "Load Testing Jmeter On Kubernetes" on our medium blog post:
https://github.com/kubernauts/jmeter-kubernetes
https://github.com/kubernauts/jmeter-operator
https://blog.kubernauts.io/load-testing-as-a-service-with-jmeter-on-kubernetes-fc5288bb0c8b

