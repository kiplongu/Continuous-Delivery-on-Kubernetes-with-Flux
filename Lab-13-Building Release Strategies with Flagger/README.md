# Lab 13. Building Release Strategies with Flagger
# Deploying Flagger
Examine the following path in the flagger branch of the flux-fleet repository on GitHub:
├── infra
│
├── base
│
│
└── flagger
│
│
├── kustomization.yaml
│
│
└── namespace.yaml
│
└── staging
│
├── flagger.yaml
│
└── kustomization.yaml
Merge the changes from the lfs269/flagger branch in your main branch and push it to your
repository as in:

cd flux-fleet/
git branch
git remote show origin
git pull origin
git remote add lfs269 https://github.com/lfs269/flux-fleet.git
git config pull.rebase false
git pull lfs269 flagger
git push origin main

After these changes are pushed, watch it automatically:

Create a flagger-system namespace
Deploy the Flagger App
Set up Prometheus
Launch the Load Test Service

Validate by running:
flux get kustomizations -A
kubectl get all -n flagger-system
Without you bothering about any of the setup... Well, that's the power of using GitOps. You
could simply deploy stuff with a pull request.

# Deploying nginx-controller
Now, let's also go ahead and merge the nginx-ingress branch from lfs269/flux-fleet
to your flux-fleet repo’s main using the following commands and watch the nginx ingress
controller getting deployed:
git pull lfs269 nginx-ingress
git push origin main
Validate by running:
flux get sources all -n flagger-system
flux get helmreleases -n flagger-system
kubectl get all -n flagger-system
At this time, you can find the External IP of the load balancer from the output of the last
command above:
service/flagger-system-nginx-ingress-ingress-nginx-controller
LoadBalancer
10.8.128.119
34.173.138.183
80:31080/TCP,443:31443/TCP
105s

This is expected, as the nginx ingress controller is set up and now expects you to send requests
with hostname instead of an IP address. This validates you have a working nginx ingress
controller set up.