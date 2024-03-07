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