Set Up the Kubernetes Staging Cluster on GKE

Set up a Google Cloud account by browsing to https://cloud.google.com/free.
Once your account is set up, login and browse to the cloud console by visiting
https://console.cloud.google.com/
From Navigation select Compute → Kubernetes Engine (GKE) → Clusters

This will open a new cluster creation wizard as follows. Select LETS GET STARTED to proceed.
From the next page, select the default options without changing anything and proceed to create
Cluster using Auto Pilot Configurations:


Set Up Firewall Rules to Allow Access to Applications
From Networking → VPC Network select Firewall.

From the available firewall rules, select the one which matches gke-autopilot-cluster-xxx-all.
Look for the word all and click on that option.
Click on Edit when presented with Firewall rule details.
From the Action on Match section:
1. Add the Source IP Rage as 0.0.0.0/0.
2. Select Allow All from Protocols and ports.
3. Click on Save.

This will allow the services that you expose with NodePort to be accessed from outside the
cluster.

Set Up the Visualizer

The Visualiser is a third party open source application which helps you visualize not only your
cluster nodes, but also the application workloads running as workloads on top of this cluster.
Once you are done setting up the cluster using the instructions above, open a cloud shell and type in the following commands:

git clone https://github.com/schoolofdevops/kube-ops-view
kubectl apply -f kube-ops-view/deploy/

You could access the visualizer by discovering the External IP address of any of the nodes and
by browsing to http://NODEIP:32000.

To find the NodeIP (External IP) run the following command in the Cloud Shell:
kubectl get nodes -o wide
where External-IP will show you the IP that you can use to connect to the cluster nodes over
NodePort such as above (e.g. 32000).

![visualizier](nodeip.png)


Configure the Staging Context with Google Cloud SDK

On the workstation you set up earlier, install Google Cloud SDK by following the instructions
provided in the Installing Google Cloud SDK | Cloud SDK Documentation.
On Ubuntu, you could use the following sequence of commands to do so:
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg]
https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a
/etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get install -y
apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo
apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install -y google-cloud-sdk
apt-get install google-cloud-sdk-gke-gcloud-auth-plugin

f you are using a remote server, while initializing gcloud, use the following command:
gcloud init --console-only
When presented with the following choices pick [2]:
Choose the account you would like to use to perform operations for
this configuration:
[1] 941896312692-compute@developer.gserviceaccount.com
[2] Log in with a new account
Please enter your numeric choice: 2
From the next prompt, chose Y:
to switch accounts if necessary.
Your credentials may be visible to others with access to this
virtual machine. Are you sure you want to authenticate with
your personal account?
Do you want to continue (Y/n)? Y
Browse to the link presented, which would let you login to your Google account and provide
authorization.

Once authorized, you would have to:

Paste the verification code back to Console
Select the project to use
Optionally, define the default region
to complete the Google Cloud SDK setup.
Configure kubectl to Connect with the GKE Cluster
From the GKE Console, select the cluster options and choose Connect:
Copy over the command displayed on the screen which starts with gcloud and sets up the
kubectl configurations:

For example:

gcloud container clusters get-credentials staging --zone xxx --project
gitops-yyy

Once executed, you should be able to validate the configuration has been added and the
kubectl context is set by running the following command:

kubectl config get-contexts

As you can see, a new context with the GKE cluster has been added and selected as default.
You could switch contexts with the use-context command as in:
kubectl config get-contexts
kubectl config use-context kind-kind
kubectl config get-contexts
kubectl config use-context gke_gitops-309305_us-central1-c_staging
[replace gke_gitops-309305_us-central1-c_staging with actual name of
the context]
kubectl config get-contexts
Ensure you replace the context names with the actual ones.
To further validate, try listing all the pods. This should show the relevant pods from the cluster
chosen.
kubectl get pods --all-namespaces



Bootstrap Flux for the Staging Cluster

Check the prerequisites:

A configured Kubernetes cluster (e.g. the GKE cluster created above)
Git repository (flux-infra)
Git user and token configured in the environment.
Begin by running a pre-flight check:
flux check --pre
To bootstrap the staging cluster with the existing flux-infra repo, run the following
command:
flux bootstrap github
--owner=$GITHUB_USER
--repository=flux-infra \
--branch=main \
--path=./clusters/staging \
--personal \
--log-level=debug \
--network-policy=false
______________________

Rename Cluster Contexts

kubectl config rename-context gke_gitops-xxx staging
kubectl config rename-context kind-kind dev
Note: replace the context names with the actual ones.
Now list the Flux components with default and specific Kubernetes contexts, as in:
flux get kustomizations
flux get kustomizations --context=dev
flux get sources git
flux get sources git --context=dev