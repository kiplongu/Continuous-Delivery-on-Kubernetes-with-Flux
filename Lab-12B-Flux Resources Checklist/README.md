# Lab 12B. Flux Resources Checklist
You could use the following checklist to find out what has been created so far to tally
against the YAML manifests available.

# Common
● Sources
● GitRepository

● Secrets
● App Namespace
● dockerhub-creds : used by the kaniko tekton task to push an
image to Docker Hub
● Flux System Namespace
● webhook-token : Used by the notification service
● slack-url : To send Slack alerts
● gitHub-token :
● github-instavote : Used by the image automation controller to
commit image tags to GitHub.
● Notifications
● Slack
● Provider
● Alert : To send flux cluster-wide status to Slack
● GitHub
● Provider : To send alerts to GitHub
● Receiver : To receive incoming webhooks for GitHub

# Application Specific
● Vote
● Kustomization : To deploy the vote service to k8s
● Alert : To update git commit status checks
● ImageRepository : To scan image repo
● ImagePolicy : To find the latest image
● ImageUpdateAutomation : To commit the latest image back to git
repo

Redis
● Kustomization : To deploy redis service to k8s
● Alert : To update git commit status checks
Worker
● Kustomization: To deploy worker service to k8s
● Alert: To update git commit status checks
DB
● HelmRepository: To fetch the helm charts from
● HelmRelease: To create helm release and deploy to k8s
Result
● HelmRelease: To create helm release and deploy to k8s
● ImageRepository: To scan image repo
● ImagePolicy: To find the latest image
● ImageUpdateAutomation: To commit latest image back to git repo