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