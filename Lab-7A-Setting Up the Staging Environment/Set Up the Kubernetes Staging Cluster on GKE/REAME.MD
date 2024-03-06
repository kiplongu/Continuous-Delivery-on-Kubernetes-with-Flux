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
