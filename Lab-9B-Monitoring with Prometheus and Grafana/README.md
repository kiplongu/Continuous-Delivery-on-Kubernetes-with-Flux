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

Validate:
flux get kustomizations
Now, suspend the monitoring kustomization and change the service type to NodePort.
flux suspend kustomization kube-prometheus-stack

kubectl get services -n monitoring
kubectl patch service kube-prometheus-stack-grafana -p
'{"spec":{"type": "NodePort"}}' -n monitoring
Note the NodePort defined for Grafana:
kubectl get service kube-prometheus-stack-grafana -n monitoring
[sample output]
NAME
TYPE
CLUSTER-IP
EXTERNAL-IP
PORT(S)
AGE
kube-prometheus-stack-grafana
NodePort
10.111.227.109
<none>
3000:30579/TCP
13h
Here NodePort is set to 30579.
Now you could access Grafana using http://<NodeIP>:<NodePort>
with the following credentials:
username: admin
password: prom-operator
Once logged in, explore the Grafana dashboards.