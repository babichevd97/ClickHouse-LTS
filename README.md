# ClickHouse Long-Term Storage simple sandbox
This is a simple hands-on chart for trying out how does ClickHouse-Graphite-Carbon bundle works as a Long-Term Storage. It is not suitable for production usage, but it can form a basis for such

## Related documentation
- https://clickhouse.com/docs/en/engines/table-engines/mergetree-family/graphitemergetree - ClickHouse GraphiteMergeTree Engine documentation
- https://github.com/go-graphite/graphite-clickhouse/ - graphite-clickhouse documentation
- https://github.com/go-graphite/carbon-clickhouse - carbon - clickhouse documentation
- https://thin-record-006.notion.site/Using-Clickhouse-as-long-term-storage-for-Prometheus-449b1c3a0a8b4cdb90b7352f807d6487?pvs=4

## Requirements
You need to be installed on yout tested system:
    - Helm
    - Docker
    - Running Kubernetes cluster (Single-node is also ok)

 ## Notes
 - For simplicity, all deployments are single-scaled, and no external volumes. You Can adjust it for more serious tests
 - Each service is exposed as a NodePort, so you will have an oportunity to discover each running service from you localhost. **If you are using minikube, you will face some problems with NodePort service type, as minikube works with this objects not in the same way kubernetes does it. You will need to run a service tunnel**. More info here: https://minikube.sigs.k8s.io/docs/handbook/accessing/
 - Kubernetes namespace click-graphite is created by default
 - Only NodePorts and User/Pass creds are templated

## Usage
- Pull this repository locally, using git pull
- Cd to repository
- Edit values.yaml file or create your own CustomValues.yaml - file
- Run: 
    ```bash
    helm -n click-graphite install -f CustomValues.yaml clickhouse-longstorage .
    ```