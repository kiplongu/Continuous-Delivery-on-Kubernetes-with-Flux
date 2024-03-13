# Lab 9B. Monitoring with Prometheus and Grafana

# Create a source to sync with the monitoring repo:

flux create source git flux-monitoring \
--interval=30m \
--url=https://github.com/fluxcd/flux2 \
--branch=main


# Create a Kustomization to deploy Prometheus and Grafana:
flux create kustomization kube-prometheus-stack \
--interval=1h \
--prune \
--source=flux-monitoring \
--path="./monitoring/controllers/kube-prometheus-stack" \
--health-check-timeout=5m \
--wait \
--export

flux create kustomization monitoring-config \
--depends-on=kube-prometheus-stack \
--interval=1h \
--prune=true \
--source=flux-monitoring \
--path="./monitoring/configs" \
--health-check-timeout=1m \
--wait \
--export
