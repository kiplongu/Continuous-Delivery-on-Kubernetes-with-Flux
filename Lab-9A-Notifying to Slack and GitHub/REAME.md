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