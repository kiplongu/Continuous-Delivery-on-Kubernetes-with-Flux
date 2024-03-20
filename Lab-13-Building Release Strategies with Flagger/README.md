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


# Deploying with Blue/Green Strategy

Study the canary configuration for vote app from setup/vote-canary.yaml at main ·
lfs269/setup · GitHub
Copy over to contents of
https://raw.githubusercontent.com/lfs269/setup/main/flagger/vote-canary.yaml and add it
as a file: instavote-deploy/kustomize/vote/base/canary.yaml
Update canary.yaml with the actual Cluster/External IP of the Ingress Controller. Use
kubectl get svc -n flagger-system to find this IP
Update the base kustomization for vote as:
file: instavote-deploy/kustomize/vote/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- hpa.yaml
- ingress.yaml
- canary.yaml

Add the analysis configuration for the Blue/Green release with the following values:
● interval = 30s [wait for this long to get the metrics to analyze]
● threshold = 3 [fail if errors are greater than this]
● iterations = 5 [how many times to run analysis to ensure the app is stable]
file: kustomize/vote/staging/canary.yaml

apiVersion: flagger.app/v1beta1
kind: Canary
metadata:
name: vote
namespace: instavote
spec:
analysis:
interval: 30s
threshold: 3
iterations: 5

Update kustomization.yaml to add canary.yaml as a patch.
file: kustomize/vote/staging/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
patchesStrategicMerge:
- deployment.yaml
- canary.yaml
....
... file continues
Path: instavote-deploy/kustomize/vote/staging
kustomize build
Commit changes and push to GitHub.

instavote-deploy/kustomize/vote
git add *
git status
git commit -am "adding canary configs"
git push origin main
Reconcile:
flux reconcile kustomization -n instavote vote-staging --with-source
Once reconciled, validate with:
kubectl get all -n instavote
kubectl describe canary vote -n instavote
kubectl describe ing -n instavote

At this time you should see a new deployment named vote-primary:
deployment.apps/vote
2d19h
deployment.apps/vote-primary
45s
0/000
1/111
ClusterIP10.8.129.28<none>
ClusterIP10.8.128.251<none>
ClusterIP10.8.130.194<none>
Set of services maintained by Flagger as:
service/vote
80/TCP
15s
service/vote-canary
80/TCP
45s
service/vote-primary
80/TCP
45s



# Trigger a Blue/Green Deployment
You could temporarily suspend the kustomization for vote and try rolling out by manually
setting an image.
flux suspend kustomization vote-staging -n instavote
To monitor resources in the instavote namespace without needing to provide the namespace
every time, set the context to use instavote as the current namespace.
kubectl config set-context --current --namespace=instavote
To trigger rollouts, use set commands as follows:
kubectl -n instavote set image deploy vote vote=schoolofdevops/v2
You can try rolling out a few times by updating the versions (tags from v1 to v9 are available in
the repo).

watch 'kubectl get all -o wide \
-l "kustomize.toolkit.fluxcd.io/name=vote-staging"; \
kubectl describe canary vote | tail -n 20'

Where you can observe the events related to the rollout.

watch kubectl describe ing
Where you can see in action that the nginx ingress controller is balancing traffic across:

To learn how blue/green deployments work, refer to Blue/Green Deployments - Flagger.

Note: If you do not see the release progressing, try to generate some traffic using browser
windows and sending requests to Ingress with hostname e.g. vote.example.com, refresh the
window a few times while the release is in progress.