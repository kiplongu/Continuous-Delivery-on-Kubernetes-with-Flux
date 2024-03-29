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


# Create a Pipeline Run for the Vote App
PipelineRun allows you to launch an actual CI pipeline by creating an instance of a template
(Pipeline) with application-specific inputs (resources).
Edit the vote-ci-pipelinrun.yaml file with actual values. Following are the parameters
displayed from the pipeline run file:
params:
- name: repoUrl
value: https://github.com/xxxxxx/instavote.git
- name: revision
value: main
- name: sparseCheckoutDirectories
value: /vote/
- name: imageUrl
value: xxxxxx/vote
- name: pathToContext
value: vote
Replace values for:
repoUrl: to point to the repository where your application source is
imageUrl: to point to your Docker Hub / Registry user/org ID to publish the image to
Begin by listing the Pipelines and PipelineRuns as:
tkn p list
tkn pr list
Launch a pipeline run for the vote app as:
kubectl create -f vote-ci-pipelinerun.yaml

Validate and watch the pipeline run with:
tkn pr list
tkn pr logs -f vote-xxxxx
Where you replace xxxxx with the actual name of the pipeline run.
You may see that the pipeline run exits with an error or hangs while trying to push the image to
the registry. This is expected as Kaniko needs registry secrets in order to authenticate and push
a container image.



# Set Up Continuous Integration for the Result App
Since you already have a template in the form of a pipeline, setting up CI for the result app is
just a matter of creating an instance of it, by providing application-specific (result app) inputs.
That's what you do by creating a pipeline run object.
You will find the pipeline run spec in the same repository you have cloned along with the code
for the vote pipeline run.
Update the params as earlier.
file: result-ci-pipelinerun.yaml
params:
- name: repoUrl
value: https://github.com/initcron/instavote.git

- name: revision
value: master
- name: sparseCheckoutDirectories
value: /result/
- name: imageUrl
value: initcron/tknresult
- name: pathToContext
value: result

kubectl create -f result-ci-pipelinerun.yaml
Validate and watch the pipeline run with:
tkn pr list
tkn pr logs --last --follow --all
Validate by checking if the container image is published on Docker Hub for the result app.

# References

Install Tekton Getting Started | Tekton
Tekton Core Concepts Concepts | Tekton
Tekton Catalogue GitHub - tektoncd/catalog: Catalog of shared Tasks and Pipelines.
Tekton Official Page Tekton
Tekton Triggers triggers/docs/getting-started at v0.10.1 · tektoncd/triggers · GitHub