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