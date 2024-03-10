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