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