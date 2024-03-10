# Lab 8. Deploying Helm Charts with Flux

Use Helm to deploy a chart from an existing third party Helm repository.
Set up automated deployment of charts with the Helm Controller AND the HelmRelease
Resource.
Generate a simple Helm chart and deploy it with Flux.
Install Helm v3
To install Helm version 3, you can follow these instructions:
curl
https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
| bash
Source: Helm | Installing Helm
Verify the installation is successful:
helm —help
helm version