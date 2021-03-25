# Start minikube and connect kubectl and docker to it:
```
minikube start --cpus=4 --memory=4g
kuse ~/.kube/minikube_config

export DOCKER_TLS_VERIFY=1;
export DOCKER_HOST=tcp://$(docker container port minikube 2376);
export DOCKER_CERT_PATH=/mnt/c/Users/sakar/.minikube/certs;
```
# Build own image to minikube and start locust:
```
docker build -t sakenlocust:1.0.0 .
helm repo add locust 'https://raw.githubusercontent.com/hansehe/locust/master/helm/charts'
helm repo update
helm install --set image.repository=sakenlocust,image.pullPolicy=Never,locustFile=/src/tasks.py sakenomalocust locust/locust
```
# Kick up own webserver what to test:
```
helm repo add mirantis https://charts.mirantis.com
helm repo update
helm install sakewebbi mirantis/nginx
```
# Take connection to locust:
```
kubectl --namespace default port-forward service/sakenomalocust-master 8080:80
http://localhost:8080
Use own web server as SUT host: http://sakewebbi-nginx
```

# Download jmeter format results e.g:
```
shoisko@DuuniWin10:~/tmp$ kubectl exec -it sakenomalocust-master-85f87fbf66-q4bzk -- ls
__pycache__    requirements.txt                 tasks     tools
locustfile.py  results_2021_03_23_11_46_48.csv  tasks.py
shoisko@DuuniWin10:~/tmp$ kubectl cp sakenomalocust-master-85f87fbf66-q4bzk:results_2021_03_23_11_46_48.csv results_jmet
er.csv
``` 

# Source of idea:
https://github.com/joakimhew/locust-kubernetes
https://github.com/hansehe/locust/