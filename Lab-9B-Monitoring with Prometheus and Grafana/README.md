# Lab 9B. Monitoring with Prometheus and Grafana

# Create a source to sync with the monitoring repo:

flux create source git flux-monitoring \
--interval=30m \
--url=https://github.com/fluxcd/flux2 \
--branch=main