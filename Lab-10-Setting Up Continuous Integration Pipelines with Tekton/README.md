# Lab 10. Setting Up Continuous Integration Pipelines with Tekton



In this lab you are going to learn:

How to set up Tekton for Kubernetes Native CI
Add various Tekton Tasks
Create Pipelines and execute those with PipelineRuns
Prerequisites:

A working Kubernetes cluster
kubectl configured with the context set to connect to this cluster
Default storage class available in the cluster to provision volumes dynamically

# Install Tekton
kubectl apply --filename
https://storage.googleapis.com/tekton-releases/pipeline/latest/release
.yaml
To understand what gets created, run the following commands:
kubectl get ns
kubectl get all -n tekton-pipelines
kubectl get configmap,secret,serviceaccount,role,rolebinding -n
tekton-pipelines

kubectl get crds | grep -i tekton
To install the Tekton CLI (tkn), please refer to the instructions specific to your OS from this
page: https://github.com/tektoncd/cli
Follow these instructions to install the Tekton CLI on Ubuntu:
curl -LO
https://github.com/tektoncd/cli/releases/download/v0.31.0/tektoncd-cli
-0.31.0_Linux-64bit.deb
dpkg -i tektoncd-cli-0.31.0_Linux-64bit.deb
Validate:
tkn
tkn version
Some Tekton subcommands:

# Set Up Continuous Integration Pipeline with Tekton

# Set Up Prerequisite Tekton Tasks
Begin to create the following prerequisite tasks:

git-clone: used to clone the source repository and pass on the latest commit hash to
other tasks
kaniko: used to build Docker images and publish those to the registry. This is a cleaner
Kubernetes native solution than using Docker-based image builds.
You can search for a catalog of tasks that comes with Tekton from:

Tekton Hub (beta): Tekton Hub
Tekton Catalog Repo: GitHub - tektoncd/catalog: Catalog of shared Tasks and Pipelines.
To add the git-clone task, run:

tkn hub install task git-clone
Similarly, install the Kaniko task, which would read the Dockerfile and build an image out of it.
To install the Kaniko task:
tkn hub install task kaniko
tkn t list

# Create a Tekton Pipeline Resource
tkn p list
tkn t list
git clone https://github.com/lfs269/tekton-ci.git
cd tekton-ci/base
kubectl apply -f instavote-ci-pipeline.yaml
Validate:
tkn p list
tkn p describe instavote-ci