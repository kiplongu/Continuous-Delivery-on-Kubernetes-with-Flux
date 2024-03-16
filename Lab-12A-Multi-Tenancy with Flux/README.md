#Lab 12A. Multi-Tenancy with Flux
In this lab you are going to learn:

How to create a repository to manage the Fleet
Carve out a new project deployment repository out of the existing app repo
How to onboard your project to a multi-tenant Flux environment
Prerequisite - Exporting Flux Resources into YAML Manifests
As part of the previous labs, there have been certain resources that you generated manually
e.g. secrets to provide sensitive data such as tokens, API urls, credentials, etc. There are other
resources which you may not have exported and created YAMLs for. It's important to take a
stock of all such resources and generate YAML manifests for the same.

# Generate Manifests for Secrets
kubectl get secrets
kubectl get secrets -n flux-system
Generate secrets YAML using:
kubectl get secrets dockerhub-creds -o yaml >
dockerhub-creds-secret.yaml
kubectl get secrets -n flux-system -o yaml
github-instavote-secret.yaml
github-instavote
>
kubectl get secrets -n flux-system -o yaml github-token >
github-token-secret.yaml

kubectl get secrets -n flux-system -o yaml slack-url >
slack-url-secret.yaml
kubectl get secrets -n flux-system -o yaml webhook-token >
webhook-token-secret.yaml
Note: Edit the secret YAMLs generated above to strip them from unnecessary information.
An example of a stripped down secret spec is as follows:
apiVersion: v1
data:
password: Z2hwX3BDZTVNdVc4ZmU5QXljYkZhUVQ2VmVkbUw0clV6ejBOb2NiNg==
username: ZG9wc2RlbW8=
kind: Secret
metadata:
name: github-instavote
namespace: flux-system
type: Opaque

You could temporarily move those secrets to a local directory instead of committing those to the
Git repo.
E.g.
mkdir ~/secrets
mv *secret* ~/secrets/