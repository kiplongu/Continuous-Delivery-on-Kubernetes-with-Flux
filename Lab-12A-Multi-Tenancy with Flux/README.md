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

# Export Flux Sync Manifests
You have already exported and committed most of the Flux resources as part of the previous
labs. If you have not, you could use the flux get command to list the resources, followed by
flux export which generates the YAML code which can then be redirected to a file and be
added to git.
For example, let's assume you have not added the sync manifest for the notification receiver
you had created earlier.
To list the receivers use:
flux get receiver

Now, to display the YAML generated for this receiver, as well as to add this content to a file, use
a tee command as follows:
flux export receiver instavote | tee instavote-receiver.yaml
You now have a sync manifest for the receiver created at instavote-receiver.yaml.
You can reference the Flux Resources Checklist (Lab 12B) provided along with this lab guide
to tally manifests against resources created so far.
Commit All the Pending Manifests
git add *.yaml
git commit -am "checking in all the pending manifests"
git push origin main

# Reset the Existing Environment
Uninstall Flux components:
flux check
flux uninstall --namespace=flux-system --dry-run
flux uninstall --namespace=flux-system
flux check
Now clean up any application deployments running on the cluster.
Use the following command to determine what has been running on this cluster and which
namespaces need a clean up:
kubectl get pods --all-namespaces
You could delete all the objects for a project by deleting a namespace.
kubectl delete namespace instavote

Wait for a couple of minutes for everything to be cleaned up.
Deleting a namespace pending termination
If you notice a namespace which is pending termination for more than a few minutes, it is likely
due to a pending finalizer. You could try fixing this issue by using the following sequence. Make
sure you replace xxxxxx with the name of the pending namespace.
export PENDING_NAMESPACE=xxxxxx
kubectl get namespace $PENDING_NAMESPACE -o json
| tr -d "\n" | sed
"s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/"
| kubectl replace
--raw /api/v1/namespaces/$PENDING_NAMESPACE/finalize -f -
Source: Delete a namespace which is pending termination due to a finalizer. · GitHub


# Rebootstrapping Staging with Fleet Repo and a Tenant
Create the Fleet Repository
Fork this repository (GitHub - lfs269/flux-fleet) to create your own flux-fleet repository.
Observe the configurations in the following repos to understand the structure and purpose of
each:
Fleet Repo : GitHub - lfs269/flux-fleet
Project Deployment (Tenant) : GitHub - lfs269/facebooc-deploy
Application Source Code : GitHub - lfs269/facebooc: Yet another Facebook clone
written in C
Bootstrap the staging cluster with a Demo Application Project as a Tenant. You are going to
use the same command as earlier, however you would change the repository to flux-fleet
this time.
flux checkflux bootstrap github
--owner=$GITHUB_USER \
--repository=flux-fleet \
--branch=main \
--path=./clusters/staging \
--personal \
--log-level=debug \
--network-policy=false \
--components-extra=image-reflector-controller,image-automation-controller

Validate that the cluster has been bootstrapped and is ready with all Flux components:
flux check
kubectl get crds
kubectl get all -n flux-system
Check whether the same project facebooc has been onboarded:
flux get kustomization
Check whether the facebooc project has been reconciled with the master:
flux get kustomization
kubectl get ns
kubectl get all -n facebooc

# Onboarding Your Project to a Multi-Tenant Flux Environment
Initialize the Deploy Repo
Create a new repository called instavote-deploy to host the Project Deployment Code.
Clone this repository, switch to the root of the repo and create the scaffold for the deployment
repo:
curl -fsSL
https://raw.githubusercontent.com/lfs269/setup/main/setup_project_repo
.sh | bash -
Validate
tree

Commit and push this structure with:
git add *
git commit -am "generated deploy repo scaffold"
git push origin main

# Migrate the Deployment Code
Copy over the deploy code from the app repository i.e. xxxx/instavote repository to the
newly created instavote-deploy repo.
export DEPLOY_REPO=<absolute_path_to_deploy_repo>
cd instavote/deploy
cp -r charts/* $DEPLOY_REPO/helm/charts/
cp -r vote worker redis $DEPLOY_REPO/kustomize/
From your previous flux-infra repository, copy over the existing flux sync manifests from
clusters/staging/ to the instavote-deploy/flux/base/ path.
.
├── flux
│
├── base
│
│
└── < copy all flux sync manifests here... >
cd ~/flux-infra/clusters/staging/
cp *.yaml $DEPLOY_REPO/flux/base/

From the instavote-deploy/flux/base path, generate a new kustomization.yaml as
in:
kustomize create --autodetect
Validate by running:
cat kustomization.yaml
Check in all the code added to the instavote-deploy path:
cd instavote-deploy
git add *
git status
git commit -am "adding deployment repo code"
git push origin main

# Import Secrets
Switch to the path which contains the secrets directory.
ls secrets/
kubectl create namespace instavote
kubectl apply -f secrets/
kubectl get secrets
kubectl get secrets -n flux-system

flux create image repository vote --image=kiplongu/vote --interval=1m --export > vote-imagerepository.yaml
flux create image repository result --image=xxxxx/result --interval=1m

# Modify Sync Manifests
What should change?
GitRepository source should now point to instavote-deploy instead of instavote
as earlier.
Image Update Automation should now push to instavote-deploy instead of
instavote
Path to helm and kustomize relative to GitRepository should now point to
● helm/chart instead of /deploy/helm
● and kustomize/ instead of /deploy/
cd $DEPLOY_REPO/flux/base/
grep github * | grep instavote
grep deploy *
The following is a list of files you may have to modify:
✳ GitHub Repo URL :
instavote-gitrepository.yaml
github-instavote-provider.yaml
Paths:
● redis-staging-kustomization.yaml
● result-helmrelease.yaml or result-staging-helmrelease.yaml
● result-imageupdateautomation.yaml
● vote-imageupdateautomation.yaml
● vote-staging-kustomization.yaml
● worker-staging-kustomization.yaml
Repo and Paths:
● vote-imageupdateautomation.yaml
● result-imageupdateautomation.yaml

# Add a Patch to flux-system
You would have to add the patch to expose the webhook receiver to flux-system again.
Make sure you have cloned your own copy of the flux-fleet repo. If not, do so before
proceeding.
git clone https://github.com/xxxxxx/flux-fleet.git
Replace xxxxxx with actual.
Start by adding the patch file:
File :
flux-fleet/clusters/staging/flux-system/expose-webhook-receiver.yaml
apiVersion: v1
kind: Service
metadata:
name: webhook-receiver
namespace: flux-system
spec:
ports:
- name: http
port: 80
protocol: TCP
targetPort: http-webhook
nodePort: 31234
selector:
app: notification-controller
type: NodePort
And update the kustomization.yaml to apply the patch.
File: flux-fleet/clusters/staging/flux-system/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- gotk-components.yaml
- gotk-sync.yaml
patchesStrategicMerge:
- expose-webhook-receiver.yaml
Commit the changes as in:
cd flux-fleet/clusters/staging/flux-system/
git add expose-webhook-receiver.yaml
git commit -am "add patch to expose webhook receiver"
git push origin main

# Prepare the Project for Onboarding
Your project directory for onboarding instavote should look like:
└── projects
├── base
│
└── instavote
│
├── instavote-deploy-gitrepository.yaml
│
├── instavote-deploy-kustomization.yaml
│
├── kustomization.yaml
│
└── rbac.yaml
└── staging
├── instavote-deploy-kustomization.yaml
└── kustomization.yaml
To get there, begin by adding the project directory:
cd flux-fleet
mkdir projects/base/instavote


# Create RBAC for the Project/Tenant with Flux:
flux create tenant instavote
--with-namespace=instavote \
--export > ./projects/base/instavote/rbac.yaml