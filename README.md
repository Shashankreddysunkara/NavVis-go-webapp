# golang app

[![license](https://img.shields.io/github/license/Shashankreddysunkara/NavVis-go-webapp?style=for-the-badge)](https://github.com/Shashankreddysunkara/NavVis-go-webapp/blob/main/LICENSE)
[![report](https://goreportcard.com/badge/github.com/Shashankreddysunkara/NavVis-go-webapp?style=for-the-badge)](https://goreportcard.com/report/github.com/Shashankreddysunkara/NavVis-go-webapp)
[![workflow](https://img.shields.io/github/workflow/status/Shashankreddysunkara/NavVis-go-webapp/check?label=check&style=for-the-badge&logo=github)](https://github.com/Shashankreddysunkara/NavVis-go-webapp/actions?query=workflow%3Acheck)
[![release](https://img.shields.io/github/release/Shashankreddysunkara/NavVis-go-webapp?style=for-the-badge&logo=github)](https://github.com/Shashankreddysunkara/NavVis-go-webapp/releases)

## Preface

Containerized golang app 

As per the task 2, I have created the following items:
1. Dockerfile: To build the container image for this app
2. Helm chart to deploy the golang app (without the webserver) 
3. Deploy the Let's Encrypt ssl with subdomain.
4. Added the terraform code to deploy the standalone k8s(v19.2.0) in EC2 instance with single master.

### Dockerfile and steps to build golang app

Steps to build docker image and push to docker hub

```
docker build . --tag=dock101/go-webapp-sample:latest
docker push dock101/go-webapp-sample:latest
```

### Steps to deploy EC2 instance with terraform

Pre-requisite => awscli, and terraform needs to be installed 

1. Configure the machine with aws credentials using the below command (NOTE: Best-practice would be to use awsvault to store creds in awsconfig in aws account and generated temporary token as local creds)
```
aws configure
```
2. Execute the below command to setup the EC2 instance
```
cd infra/terraform/
./run.sh
```
Note: 
The above terraform code will create new VPC, EC2 (t2.medium), SG and installs the k8s with single master SSH key and Kubeconfig which will be found in the same folder.


### Steps to deploy Helm chart

Pre-requisite => Make sure kubectl is installed and configured the kube config on your local machine.

Alternatively, you can SSH into the EC2 instance which got created with the above steps and then perform the following steps:

1. Install the go-webapp helm chart using the below command

```
cd infra/helm-charts
helm install go-webapp ./go-webapp
```

3. Confirm that the go webapp Pods have started:
```
kubectl get pods -w
```

4. Setting Up the Kubernetes Nginx Ingress Controller
```
cd infra/helm-charts/ingress-nginx/
kubectl apply -f ingress_controler.yaml
```
You should then see the output which looks similar to below output:

Output:
```
namespace/ingress-nginx created
serviceaccount/ingress-nginx created
configmap/ingress-nginx-controller created
clusterrole.rbac.authorization.k8s.io/ingress-nginx created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx created
role.rbac.authorization.k8s.io/ingress-nginx created
rolebinding.rbac.authorization.k8s.io/ingress-nginx created
service/ingress-nginx-controller-admission created
service/ingress-nginx-controller created
deployment.apps/ingress-nginx-controller created
validatingwebhookconfiguration.admissionregistration.k8s.io/ingress-nginx-admission created
clusterrole.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
job.batch/ingress-nginx-admission-create created
job.batch/ingress-nginx-admission-patch created
role.rbac.authorization.k8s.io/ingress-nginx-admission created
rolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
serviceaccount/ingress-nginx-admission created
```
Confirm that the Ingress Controller Pods have started:
```
kubectl get pods -n ingress-nginx \
  -l app.kubernetes.io/name=ingress-nginx --watch
```

5. Setting Up the Kubernetes Nginx Ingress Resource (HTTPS)
```
cd infra/helm-charts/ingress-nginx/
kubectl apply -f https_ingress_letsencrypt.yaml
```

6. Installing and Configuring Letsencrypt Cert-Manager
```
kubectl apply --validate=false -f cert-manager.yaml
```
To verify our installation, check the cert-manager Namespace for running pods:

```
kubectl get pods --namespace cert-manager
```

You can use kubectl describe to track the state of the Ingress changes you’ve just applied:

```
kubectl describe ingress
```

Once the certificate has been successfully created, you can run a describe on it to further confirm its successful creation:

```
kubectl describe certificate
```

## License
The License of this sample is *MIT License*.
