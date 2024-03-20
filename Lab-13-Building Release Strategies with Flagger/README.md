# Lab 13. Building Release Strategies with Flagger
# Deploying Flagger
Examine the following path in the flagger branch of the flux-fleet repository on GitHub:
├── infra
│
├── base
│
│
└── flagger
│
│
├── kustomization.yaml
│
│
└── namespace.yaml
│
└── staging
│
├── flagger.yaml
│
└── kustomization.yaml
Merge the changes from the lfs269/flagger branch in your main branch and push it to your
repository as in:

cd flux-fleet/
git branch
git remote show origin
git pull origin
git remote add lfs269 https://github.com/lfs269/flux-fleet.git
git config pull.rebase false
git pull lfs269 flagger
git push origin main

After these changes are pushed, watch it automatically:

Create a flagger-system namespace
Deploy the Flagger App
Set up Prometheus
Launch the Load Test Service

Validate by running:
flux get kustomizations -A
kubectl get all -n flagger-system
Without you bothering about any of the setup... Well, that's the power of using GitOps. You
could simply deploy stuff with a pull request.

# Deploying nginx-controller
Now, let's also go ahead and merge the nginx-ingress branch from lfs269/flux-fleet
to your flux-fleet repo’s main using the following commands and watch the nginx ingress
controller getting deployed:
git pull lfs269 nginx-ingress
git push origin main
Validate by running:
flux get sources all -n flagger-system
flux get helmreleases -n flagger-system
kubectl get all -n flagger-system
At this time, you can find the External IP of the load balancer from the output of the last
command above:
service/flagger-system-nginx-ingress-ingress-nginx-controller
LoadBalancer
10.8.128.119
34.173.138.183
80:31080/TCP,443:31443/TCP
105s

This is expected, as the nginx ingress controller is set up and now expects you to send requests
with hostname instead of an IP address. This validates you have a working nginx ingress
controller set up.


# Setting Up Ingress
Now that the ingress controller is available, it’s time to add an ingress rule for the vote app so
that it is accessible from outside with nginx.
You would add the code to create the ingress rule for the vote app in the same place where
you are deploying all the other components related to the vote app i.e. inside the
instavote-deploy repository.

file: instavote-deploy/kustomize/vote/base/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
name: vote
namespace: instavote
labels:
app: vote
annotations:
kubernetes.io/ingress.class: nginx
spec:
rules:
- host: vote.example.com
http:
paths:
- path: /
pathType: Prefix
backend:
service:
name: vote
port:
number: 80
And add this file to kustomization.yaml.
file: instavote-deploy/kustomize/vote/base/kustomization.yaml

apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
- ingress.yaml

Commit the changes:
git add ingress.yaml
git status
git commit -am "add ingress rule for vote app"
git push origin main
and let Flux reconcile those with the cluster.
flux reconcile kustomization -n instavote vote-staging --with-source
Validate the ingress rule is added by running:
kubectl get ing -n instavote
kubectl describe ing vote -n instavote
Assuming you do not own vote.example.com you cannot manage this domain and add a global
DNS entry. However, you could make it point to the Nginx LoadBalancer/NodePort by creating a
local hosts file entry. On Unix systems, it's in the /etc/hosts file. On Windows, it's at
C:\Windows\System32\drivers\etc\hosts. You need admin access to edit this file.
For example, on a Linux or OSX, you could edit it as:
sudo vim /etc/hosts

And add an entry such as:
xxx.xxx.xxx.xxx vote.example.com
Where,
xxx.xxx.xxx.xxx is the public facing IP address of the LoadBalancer or any Node (in
case of NodePort) that Nginx is associated with.
Make sure you are adding this entry to your local workstation from where you are
launching the browser, not on any remote system.
To validate, try accessing using either:
http://vote.example.com in case of the Load Balancer or,
http://vote.example.com:<NODE_PORT> in case of NodePort service type for
Nginx.


# Changing the Flux Code to Work with Flagger
While implementing the release strategies, Flagger takes over the management of various
components of the application components deployed inside Kubernetes, which are currently
managed completely with FluxCD.
While setting up deployments for the vote app, in order for Flux not to conflict with Flagger, the
following changes are needed:
Flux should stop managing the service. It would exclusively be created and managed
by Flagger.
For the deployment, Flux should set the number of replicas to zero, and start managing
the scale using the Horizontal Pod Autoscaler. This also means Autoscaling
Configurations should be added.
Nodeport cannot be used to expose the service as Flagger will create and manage only
ClusterIP type service.
file: instavote-deploy/kustomize/vote/base/hpa.yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
name: vote
namespace: instavote
spec:
maxReplicas: 10
minReplicas: 5
scaleTargetRef:
apiVersion: apps/v1
kind: Deployment
name: vote

file: instavote-deploy/kustomize/vote/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- hpa.yaml
- ingress.yaml
Also, from kustomize/vote/staging/kustomization.yaml file:

Remove reference of service.yaml from base/kustomization.com, as well as
from staging/kustomization.com
Set the replicas count to zero for vote staging deployment.
instavote-deploy/kustomize/vote/staging/kustomization.yaml
patchesStrategicMerge:
- deployment.yaml
replicas:
- name: vote
count: 0
Commit the changes and push to GitHub.

git add *
git status
git commit -am "add hpa, remove service management"
git push origin main
Validate:
flux reconcile kustomization -n instavote vote-staging –-with-source
kubectl get all -n instavote

Where,
deployment for vote should exist, however with 0 replicas.
horizontalpodautoscaler for vote should be present
service for vote should not exist