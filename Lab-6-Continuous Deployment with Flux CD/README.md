Lab 6. Continuous Deployment with Flux CD

Prerequisites

Create a Personal Access Token with full repository access. To do so, login to your GitHub
account and go to Settings.

From account Settings, select Developer Settings.

Choose Personal Access Token and click on Generate.

Provide a name for the token, select full repo access, along with admin:repo_hook →
read:repo_hook and click on Create.

Retain the page which displays the token (one time) until you set the environment variables in
your shell permanently.

Set up the environment variables, preferably permanently, in the shell profile script by adding
the following lines in ~/.bashrc or the equivalent file for your shell.
Make sure you have replaced the values of the token and user with the actual values, by
removing < >.

export GITHUB_TOKEN=<your-personal-access-token>
export GITHUB_USER=<your-github-username>

Install Flux CLI

To set up continuous deployment with Flux, begin by downloading and installing the Flux CLI.

On Mac:

brew install fluxcd/tap/flux

On Mac or Linux using curl:

curl -s https://fluxcd.io/install.sh | sudo bash
[Sample Output]
```
[INFO] Downloading metadata
https://api.github.com/repos/fluxcd/flux2/releases/latest
[INFO] Using 2.0.0-rc.3 as release
[INFO] Downloading hash
https://github.com/fluxcd/flux2/releases/download/v2.0.0-rc.3/flux_2.0
.0-rc.3_checksums.txt
[INFO] Downloading binary
https://github.com/fluxcd/flux2/releases/download/v2.0.0-rc.3/flux_2.0
.0-rc.3_linux_amd64


For additional Operating Systems Support, please refer to the Flux Installation documentation.

To enable bash completion, add the following to ~/.bashrc
echo "source /etc/bash_completion" >> ~/.bashrc
echo ". <(flux completion bash)" >> ~/.bashrc
Also install bash-completion as needed.
e.g.
apt update
apt install bash-completion
Apply the configs to the current shell:
source ~/.bashrc_________________________

To validate, run flux followed by double Tab (press the Tab key twice), and you should see an
output similar to the following:
# flux [tab][tab]
bootstrap
completion
suspend
check
create
uninstall

Bootstrap a Flux Environment

Bootstrapping Flux means you would:

Install the components of the Flux/GitOps Toolkit, including various controllers, CRDs,
RBAC and Network Policies
Set up a repository which would be used by Flux CD. Either create a new one, or use an
existing repo provided
Set up a Deploy Key (read-only) to connect to the repository created above so that
FluxCD can sync with it
Begin with a pre-flight check:

kubectl get nodes
kubectl config get-contexts
kubectl get pods --all-namespaces

kubectl get crds
flux check --pre

If the checks pass, go ahead and set up Flux using the following bootstrap sequence:

flux bootstrap github
--owner=$GITHUB_USER \
--repository=flux-infra \
--branch=main \
--path=./clusters/dev \
--personal \
--log-level=debug \
--network-policy=false \
--components=source-controller,kustomize-controller

Source: [flux-bootstrap ·
GitHub](https://gist.github.com/initcron/4d97c508ce617200263274cc48526c79)
Validate:
flux check
[sample output]
► checking prerequisites
✔ kubectl 1.20.4 >=1.18.0-0
✔ Kubernetes 1.20.4 >=1.16.0-0
► checking controllers
✔ kustomize-controller: deployment ready
► ghcr.io/fluxcd/kustomize-controller:v0.9.3
✔ source-controller: deployment ready
► ghcr.io/fluxcd/source-controller:v0.9.1
✔ all checks passed
Expected: You should see source-controller and kustomize-controller created as
above.
To find out everything that Flux creates on the Kubernetes side, use the following commands:

kubectl get crds
kubectl get pods -n flux-system
kubectl get all -n flux-system
kubectl get clusterroles,clusterrolebindings,serviceaccounts -n
flux-system -l "app.kubernetes.io/instance=flux-system"
Also check the following on GitHub:

A repository on GitHub with the user provided in the bootstrap command (e.g.
https://github.com/xxxxxx/flux-infra)
A deploy key configured for the repository above

Kubernetes manifests to sync with the cluster inside the flux-system subdirectory.

kustomization.yaml in the same path as above, which is read by Flux CD to
determine which manifests to apply.
To check the kustomisations and sources created by Flux, run:

flux get kustomizations
flux get sources git