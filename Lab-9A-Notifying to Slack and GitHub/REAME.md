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