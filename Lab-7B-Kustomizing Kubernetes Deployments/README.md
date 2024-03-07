Lab 7B. Kustomizing Kubernetes Deployments

In this lab, you are going to learn the following:

How to create custom configuration profiles with Kustomize
How to generate the overlay file structure used by Kustomize
How to write kustomization.yaml with its key primitives
How to provide additional Kustomization configurations such as images, replicas,
generators, etc.
To continuously monitor for the deployments with the Flux Kustomization Controller, open a new
terminal and run the following command:

watch flux get kustomizations

In case of issues, you could also watch the logs using the following command:

flux logs -f --tail 10

Install the Kustomize Tool

To install the Kustomize binary using curl, use the following command:
curl -s "https://raw.githubusercontent.com/\
kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"
| bash
mv kustomize /usr/local/bin/
kustomize
Alternately, refer to Kustomize | SIG CLI to find the various options and detailed instructions to
install kustomize.

Restructure the Deployment Code for Kustomize

You have already created basic Kubernetes deployment manifests. Begin by restructuring these
configurations so that you could provide multiple overlays.
From the application repository which hosts your deployment code, run the following to create
the base + overlay structure:
cd instavote/deploy/vote
mkdir base
git mv deployment.yaml
service.yaml base/
cd base
kustomize create --autodetect
cd ..


Create Custom Configurations for Dev

Now, add the overlay files (custom configuration) for dev.
From inside the deploy/vote path:
mkdir dev
cd dev
file: deploy/vote/dev/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
creationTimestamp: null
labels:
app: vote
name: vote
spec:
minReadySeconds: 20
replicas: 3
template:
spec:
containers:
- image: schoolofdevops/vote:v4
name: vote

file: deploy/vote/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
patchesStrategicMerge:
- deployment.yaml
Commit these changes to the application deployment repo (instavote).
From /instavote/deploy/vote:
git add *
git status
git commit -am “refactored code with kustomize overlays”
git push origin main
It’s now time to update the path to the kustomization configuration in the flux-infra
repository. Update the path as:

file: ./flux-infra/cluster/dev/vote-dev-kustomization.yaml
spec:
path: ./deploy/vote/dev
Commit all the changes and push:
git commit -am "updated the path to find manifests"
git push origin main
Keep watching for the reconciliation to the dev environment:

watch flux get kustomizations --context=dev


# Deploy to Staging

Now that the overlay structure is in place, it’s time to create another configuration profile. This
time you would be deploying to staging.
Begin by creating a namespace where you would deploy the staging infrastructure.

kubectl create namespace instavote

In the application repository (instavote) which hosts the deployment code, now create a new
overlay directory named staging:

mkdir staging

And add the kustomization overlays:
file: deploy/vote/staging/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
creationTimestamp: null
labels:
app: vote
name: vote
spec:
replicas: 5
template:
spec:
containers:
- image: schoolofdevops/vote:v3
name: vote

file: deploy/vote/staging/service.yaml
apiVersion: v1
kind: Service
metadata:
creationTimestamp: null
labels:
app: vote
name: vote
spec:
ports:
- name: "80"
port: 80
targetPort: 80
nodePort: 30200
protocol: TCP

file: deploy/vote/staging/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../base
patchesStrategicMerge:
- deployment.yaml
- service.yaml
namespace: instavote
Commit these changes to the instavote repo:
cd instavote/deploy/vote
git add *
git status
[Sample Output]
Changes to be committed:
(use "git restore --staged <file>..." to unstage)
new file:
staging/deployment.yaml
new file:
staging/kustomization.yaml
new file:
staging/service.yaml
git commit -am "added kustomization overlay for staging"
git push origin main

Now, add the kustomization spec for staging to the flux-infra repo:
file: ./flux-infra/cluster/staging/vote-staging-kustomization.yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
name: vote-staging
namespace: flux-system
spec:
healthChecks:
- kind: Deployment
name: vote
namespace: instavote
interval: 1m0s
path: ./deploy/vote/staging
prune: true
sourceRef:
kind: GitRepository
name: instavote
targetNamespace: instavote
timeout: 2m0s

File: `instavote-gitrepository.yaml`
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
name: instavote
namespace: flux-system
spec:
interval: 30s
ref:
branch: main
url: https://github.com/xxxxxx/instavote.git
git add vote-staging-kustomization.yaml instavote-gitrepository.yaml
git commit -am "add kustomization for staging infra"
git push origin main
Watch for the reconciler to pick up the configuration for staging and deploy the vote
application inside the instavote namespace.
watch kubectl get all -n instavote
If you want to run the reconciliation manually:
flux reconcile kustomization flux-system

