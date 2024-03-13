# Lab 9A. Notifying to Slack and GitHub

With this lab you are going to learn:

How to Integrate Flux with Slack to send Notifications
How to update Git Commit Status on Flux Kustomisation Runs
How to configure Flux to trigger Kustomisation Runs using GitHub Webhooks

# Configuring Flux to Notify to Slack

In this lab, you are going to set up notifications to a Slack channel for Flux events such as
reconciliation or an error.

# Create an Incoming Webhook for Slack
You need to have a Slack set up and an administrator access to the Slack organization in order
to configure this.
If you do have the appropriate access, create a new channel or use an existing one and browse
to the configuration on the top right corner of the channel. Select “ More → Add Apps “
configuration, which will then redirect you to the Slack administration page.

Search for webhook and begin to install the Incoming Webhook application.
Select Add to Slack option.
Select the Slack channel you would want to configure notifications to be sent to. Click on Add
incoming webhook integration.
Once added, you would be presented with the Webhook URL. Write it to be added as a
Kubernetes secret next.
kubectl create secret -n flux-system generic slack-url
--from-literal=address=https://hooks.slack.com/services/xxx/yyy/zzz
And then validate:
kubectl describe secret -n flux-system slack-url
[sample output]
Name:
Namespace:
Labels:
Annotations:
Type:
slack-url
flux-system
<none>
<none>
Opaque
Data
====
address:
79 bytes
You must see the address field defined as a key as part of the Data section.

# Add a Provider to Connect to Slack from Flux

Check the prerequisites before creating the provider.
flux check
kubectl get crds
flux get alert-providers
Now begin to create the provider and export it as yaml without applying:
flux create alert-provider slack \
--type=slack \
--channel= xxxxx \
--secret-ref=slack-url --export

Replace xxxxx with the actual Slack channel that you would like the notifications to be sent to.
Review the configuration and then proceed to create the provider by removing the --export
option:
flux create alert-provider slack
--type=slack \
--channel=xxxxx \
--secret-ref=slack-url

Validate:

flux get alert-providers


# Set Up an Alert to Send Notifications to Slack

Now, create an Alert to send notifications to Slack using the provider created above to track the
changes for the following resources:

Kustomization/*
GitRepository/*
HelmRelease/*
flux create alert slack-notif \
--provider-ref=slack \
--event-source=GitRepository/* \
--event-source=Kustomization/* \
--event-source=HelmRelease/* \
--event-severity=info \
--export
Review the YAML and then create the alert:
flux create alert slack-notif \
--provider-ref=slack \
--event-source=GitRepository/* \
--event-source=Kustomization/*\
--event-source=HelmRelease/* \
--event-severity=info
Validate by listing alerts:

flux get alert

You should now see an alert definition added with the name slack-notif. If you start
watching the Slack channel configured with the provider configurations, you should now see
incoming notifications from FluxCD when some of the following events happen:
when reconciliation makes a change (create/update/delete)
when health checks pass after the change
when a dependency is taking longer, delaying the reconciliation
when the reconciliation fails

Once validated, generate and commit the provider + alert configurations to
flux-infra/clusters/staging as in:
flux export alert slack-notif > slack-notif-alert.yaml
flux export alert-provider slack > slack-provider.yaml
git add slack-*
git status
git commit -am "add slack notifications"
git push origin main

![Alerts Notification](image.png)


# Automating Status Notifications to GitHub

# Set Up Authentication to GitHub with a Secret
Generate a personal access token with repo access and store it as a Kubernetes secret using:
kubectl create secret -n flux-system generic github-token
--from-literal=token=xxxxxx
Replace xxxxxx with the actual token with write access to your Git repo.
Validate:
kubectl describe secret -n flux-system github-token
[sample output]
Name:github
Namespace:flux-system
Labels:
Annotations:

Type:Opaque
Data
====
token:40 bytes

# Create Providers and Alerts to Update the Commit Status
Begin by creating the core for the provider which points to the same repository that you have
configured as the GitRepository source.
flux create alert-provider github-instavote \
--type=github \
--address=https://github.com/xxxxxx/instavote \
--secret-ref=github-token --export
flux create alert-provider github-instavote \
--type=github \
--address=https://github.com/xxxxxx/instavote \
--secret-ref=github-token --export
Note: Make sure to replace https://github.com/xxxxxx/instavote with the actual repo.
It should be the same repo as defined in the GitRepository source.
Validate with:
flux get alert-providers

Now, go ahead and set up an alert which would update the commit status for the
vote-staging kustomization run:
flux create alert vote-staging \
--provider-ref=github-instavote \
--event-severity info \
--event-source Kustomization/vote-staging --export
flux create alert vote-staging \
--provider-ref=github-instavote \
--event-severity info \
--event-source Kustomization/vote-staging
Since these alerts are created with a specific kustomization which maps to one application, you
will create as many alerts matching the number of kustomizations you have. (e.g. redis,
worker).
To check the names of your customisations, run:
flux get kustomizations
Now create alerts for Redis and Worker e.g.
flux create alert redis-staging \
--provider-ref=github-instavote \
--event-severity info \
--event-source Kustomization/redis-staging
flux create alert worker-staging \
--provider-ref=github-instavote \
--event-severity info \
--event-source Kustomization/worker-staging
And validate all the alerts are in place with:
flux get alerts

Now, browse to the GitHub repo and validate that the status updates are reflected right from the
commit messages.

You may trigger a new reconciliation by updating an image for the vote application from staging
kustomization.yaml and validate further.
Once validated, don’t forget to generate and revision control the yaml manifests for these alerts
and the provider created:
flux export alert-provider github-instavote >
github-instavote-provider.yaml
flux export alert vote-staging > vote-staging-alert.yaml
flux export alert worker-staging > worker-staging-alert.yaml
flux export alert redis-staging > redis-staging-alert.yaml
git add github-instavote-provider.yaml *alert.yaml
git status
git commit -am "add git commit status"
git push origin main

# Set Up Push-Based Reconciliation
Begin by first updating the interval for all staging Kustomizations, as well as for
GitRepository to 1h so that you could test push-based reconciliation.
For example:
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
namespace: flux-system
spec:
interval: 1h
path: ./deploy/vote/staging
prune: true
file continued ...

# Expose the Webhook Receiver Service
In this use case, the push-based model would work only if your Kubernetes cluster is hosted
publicly and you could create an incoming webhook which can then be accessed from GitHub
as a source. If your Kubernetes environment is behind a firewall, you would still configure
sources such as Jenkins, Container Registries, Git services, which are privately hosted and
have access to the Kubernetes environment.

Now, go ahead and patch the webhook-receiver service so that it is exposed outside and
can be accessed by GitHub.
file:
flux-infra/clusters/staging/flux-system/expose-webhook-receiver.yaml
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

Note: Instead of the NodePort above, you could also use a LoadBalancer service with public
cloud platforms.
Now edit the following file to add patchesStrategicMerge as in:
file: flux-infra/clusters/staging/flux-system/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- gotk-components.yaml
- gotk-sync.yaml
patchesStrategicMerge:
- expose-webhook-receiver.yaml
Commit these changes and push to the GitHub repo:
git add expose-webhook-receiver.yaml
git diff
git commit -am "expose webhook receiver as nodeport"
git push origin main
Wait for a minute, or for the changes to be reconciled with the cluster, and then validate.

You could alternately run Flux once and then validate the service as:
flux reconcile kustomization flux-system
kubectl get svc -n flux-system
This time you should see the webhook-receiver service exposed on port 31234 with
NodePort as service type.

# Define an Authentication Token
Time to define an authentication token, which would be validated by the Notification Controller
for incoming webhooks.
Generate a random token and write it to be configured with GitHub later:
WEBHOOK_TOKEN=`date | md5sum | cut -d ' ' -f1`
echo $WEBHOOK_TOKEN
Store this token as a Kubernetes secret:
kubectl -n flux-system \
create secret generic webhook-token \
--from-literal=token=$WEBHOOK_TOKEN
Validate:
kubectl -n flux-system get secret webhook-token
kubectl -n flux-system describe secret webhook-token

# Create a Receiver to Accept GitHub Events
flux create receiver instavote \
--type github \
--event ping \
--event push \
--secret-ref webhook-token \
--resource GitRepository/instavote \
--export

After reviewing the YAML, create the receiver:
flux create receiver instavote\
--type github \
--event ping \
--event push \
--secret-ref webhook-token \
--resource GitRepository/instavote
Validate the Receiver is created and also fetch the webhook URL:
flux get receivers
[sample output]
NAME
READYMESSAGE
SUSPENDED
instavoteTrue Receiver initialised with URL:
/hook/3ce6b83b91ee5bf7e44485fb631f1788ea86c018ddedab511e8252cf13e527d0
False
Now generate the following and write it down:
Payload URL: http://<NODEIP>:<NODEPORT>/RECEIVER_URL
Secret: Content of the echo $GITHUB_TOKEN command
Example of a Payload URL is as follows:
http://143.198.50.211:31234/hook/3ce6b83b91ee5bf7e44485fb631f1788ea86c
018ddedab511e8252cf13e527d0