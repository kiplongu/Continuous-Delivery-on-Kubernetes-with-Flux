# Lab 8. Deploying Helm Charts with Flux

Use Helm to deploy a chart from an existing third party Helm repository.
Set up automated deployment of charts with the Helm Controller AND the HelmRelease
Resource.
Generate a simple Helm chart and deploy it with Flux.

# Install Helm v3

To install Helm version 3, you can follow these instructions:
curl
https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
| bash
Source: Helm | Installing Helm
Verify the installation is successful:
helm —help
helm version

# Install Postgres DB with Helm

Begin by ensuring you are set up with the correct Kubernetes context.
kubectl config get-contexts
Ensure that you are connected to the staging cluster and instavote namespace. You can
set the configuration using a command such as:
kubectl config set-context --current --namespace=instavote

Now, test deploying the postgres database using a Helm chart, using the lfs269 Helm
repository published using charts released here: Releases · lfs269/helm-charts · GitHub. This
time, you are going to deploy the chart directly with Helm, and not via Flux.
helm repo list
helm repo add lfs269 https://lfs269.github.io/helm-charts
helm repo list
helm repo update
helm search repo postgres
helm show all lfs269/postgres
helm show values lfs269/postgres
helm install db lfs269/postgres --set
service.name=db,settings.authMethod=trust --namespace instavote
helm list -A
[test everything]
helm uninstall db -n instavote


# Releasing Postgres HELM Chart with Flux

After testing the postgres deployment with HELM, you are now going to achieve the same using
Flux with Source and Helm Controllers.
Begin by observing the existing sources, Helm releases and kustomizations.
flux get sources all
flux get helmreleases
flux get kustomizations
flux check
Pay special attention to the sources with helmchart/xxxx.
Now, define lfs269 Helm Repository helm-charts | Helm charts for open source applications -
ready to use for deployment on Kubernetes as a source using:
flux get sources helm
flux create source helm lfs269
--url=https://lfs269.github.io/helm-charts --export
flux create source helm lfs269
--url=https://lfs269.github.io/helm-charts
flux get sources helm
file: flux-infra/clusters/staging/values.yaml
service:
name: db
settings:
authMethod: trust
Create an instance of a HelmRelease source to track and generate HelmChart for postgres
from the lfs269 Helm repository added earlier:
flux get sources all
flux get helmreleases
flux create helmrelease db --source=HelmRepository/lfs269
--chart=postgres --values=./values.yaml --target-namespace=instavote
--export
flux create helmrelease db --source=HelmRepository/lfs269
--chart=postgres --values=./values.yaml --target-namespace=instavote

Validate by running:
flux get helmreleases
flux get sources all

You should see the following objects created:

A HelmRepository source to sync with the lfs269 Helm repo
A HelmRelease object to generate and deploy a chart
A HelmChart for Postgres created out of HelmRepository using the spec
defined with the HelmRelease
It would be interesting to observe the helmchart/flux-system-db created automatically to
deploy a specific revision of the postgres chart.
Now, validate that postgres is deployed to the cluster by running:
kubectl get all

You should see a Service, StatefulSet and Pods created to deploy the database.
Finally, generate manifests and commit to the flux-infra repo’s staging cluster as:

cd flux-infra/cluster/staging
flux create source helm lfs269
--url=https://lfs269.github.io/helm-charts --export
lfs269-helmrepository.yaml
>
flux create helmrelease db --source=HelmRepository/lfs269
--chart=postgres --values=./values.yaml --target-namespace=instavote
--export > db-staging-helmrelease.yaml
rm values.yaml
git add *
git status
git commit -am "added db helm deployment"
git push origin main

# Generate a Chart for the result App

result is a user-facing application which should be deployed with the following spec:
Container image : schoolofdevops/vote-result
Service Type: NodePort
cd instavote/deploy
mkdir charts
cd charts
helm create result
cd result
Edit values.yaml to update:

The image repository and tag to schoolofdevops/vote-result:latest
The service to NodePort
file: values.yaml
image:
repository: schoolofdevops/vote-result
pullPolicy: IfNotPresent
# Overrides the image tag whose default is the chart appVersion.
tag: "latest"
service:
type: NodePort
port: 80
..... keep remaining file unchanged
file: `Chart.yaml`
appVersion: "1.0.0"
Once edited, commit the content of the charts directory and push it to GitHub:
git add *
git status
git commit -am "add chart for result app"
git push origin main

# Release a Chart Using the Git Repo as a Source

flux create helmrelease result \
--interval=10m \
--source=HelmRepository/lfs269 \
--chart=./deploy/charts/result \
--target-namespace=instavote

--export
flux create helmrelease result \
--interval=10m \
--source=HelmRepository/lfs269 \
--chart=./deploy/charts/result \
--target-namespace=instavote

Validate by running:
flux get helmreleases
flux get sources all
You should see the following objects created:
A HelmRelease object to generate and deploy a chart for the result app
A HelmChart for result created from GitRepository as source using the spec
defined with HelmRelease
Generate and commit changes to deploy the result app:
cd flux-infra/clusters/staging
flux create helmrelease result \
--interval=10m \
--source=GitRepository/vote \
--chart=./deploy/charts/result \
--target-namespace=instavote \
--export > result-staging-helmrelease.yaml
git add result-stage-helmrelease.yaml
git commit -am "added result helm release"
git push origin main


# References:

Installing Helm Helm | Installing Helm
Helm Helm
Helm Charts Helm | Charts
Overview of Helm Controller for Flux Overview - Flux | GitOps Toolkit
HelmRepository CRD Source API Reference - Flux | GitOps Toolkit
HelmRelease CRD Helm API Reference - Flux | GitOps Toolkit
Supercharge your Kubernetes Deployments - Helm YouTube
Helm Users! What Flux 2 can do for you! (Scott Rigby) YouTube