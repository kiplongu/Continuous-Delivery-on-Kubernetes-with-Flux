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