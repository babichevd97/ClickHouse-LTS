# ClickHouse Long-Term Storage simple sandbox
This is a simple hands-on chart for trying out how does ClickHouse-Graphite-Carbon bundle works as a Long-Term Storage. It is not suitable for production usage, but it can form a basis for such

## Related documentation
- [ClickHouse GraphiteMergeTree Engine documentation](https://clickhouse.com/docs/en/engines/table-engines/mergetree-family/graphitemergetree)
- [graphite-clickhouse documentation](https://github.com/go-graphite/graphite-clickhouse/)
- [carbon - clickhouse documentation](https://github.com/go-graphite/carbon-clickhouse)
- [Basics and architecture](https://thin-record-006.notion.site/Using-Clickhouse-as-long-term-storage-for-Prometheus-449b1c3a0a8b4cdb90b7352f807d6487?pvs=4)
- [Exporting metrics in Prometheus format for Yandex Clous](https://cloud.yandex.com/en/docs/monitoring/operations/metric/prometheusExport)
- [GraphiteMergeTree](https://clickhouse.com/docs/en/engines/table-engines/mergetree-family/graphitemergetree)

## Requirements
You need to be installed on yout tested system:
- Helm
- Docker
- Running Kubernetes cluster (Single-node is also ok)
- clickhouse-client

## Notes
 - For simplicity, all deployments are single-scaled. You Can adjust it for more serious tests
 **If you are using minikube, you will face some problems with NodePort service type, as minikube works with this objects not in the same way kubernetes does it. You will need to run a service tunnel**. More info here: https://minikube.sigs.k8s.io/docs/handbook/accessing/

## Folders desription
### sql
Contains sql - scripts for several purposes

### templates
Contains yaml - manifests for chart deployment

## Chart specification
To start your chart correctly, as you want, you need to prefill some parameters to make it work
### values.yaml
Start with this file. It controls components that you need to be run while deploying chart via enabled parameter.
By default only carbon, graphite and grafana are turned on

Template files have some important thins you should pay attention to, before decided what and how you want to deploy
### carbon-clickhouseExample.yaml
- In case you are using managed solution, you will need to build a custom container, that contains cloud CA - cert, that will allow incoming traffic to your cluster. Otherwise traffic will not pass. Example in repository shows how you can do it. Either you can build your custom container (example in carbon-clickhouseExample.yaml) or use a CA mapping (example in graphite-clickhouseExample.yaml). If you use your own cluster - you might not need it
- You also better check carbon-clickhouse.conf - file. Although it uses pre-defined params, you might need to change some specifications

### clickhouse-front-server.yaml
- Pay attention to volumeMounts:
    - graphite-rollup-conf - Uses basic template, but you may want to test different variations too
    - ext-clusters-rollup - **Very important**. Clickhouse need to upload this file while starting to get up-to-date information about existing clusters and shards/replica inside it. If you are using o separated cluster (front), that contacts another cluster (for example, distributed tables pointing to another cluster with replicated table), all clusters should be specified on the front - cluster
    - zookeeper-rollup - You should also configure for you cluster specs
    - You can also uncomment section with PVC - in case you are using yours
    - You can also uncomment sections with post-start sql-job, that will create distribution tables on cluster for you. In given example click-front is name of the front-clusert. prom_cluster is name of the storage cluster, where distributed tables will point

### clickhouse-server.yaml
- This deployment is an example of one-node setup. Quich way to set everything up locally
- Same graphite-config rollup rules as for front-server 
- Same rules for post-start sql-job, but basic mergeTree, as it is just single node

### grafana-server.yaml
- Runs grafana on your localhost
- Predefined datasources to configure reading from graphite and vmsingle (benchmark component) 

### graphite-clickhouseExample.yaml
- pay attention to graphite-conf file, you might want to adjust it. Values are taken from values - file, but you can hardcode them if you want
- In case you are using managed solution, you will need to upload a CAcert inside container to let incoming traffic to your cluster
Otherwise traffic will not pass. in this deployment file you can simply hardcode it, or built your custom contatiner with CA in it

### node-exporter.yaml
- basically starts scraping metrics from your local host. You can use it before testin heavy benchmarkin

### prometheus-deployment.yaml
- Simply deploys locally prometheus server
- Predefined prometheus configuration is specified. You can change remote_write endpoints to carbon-service, in case you do no write metrics via benchmark and need prometheus
- You can configure to collect performance metrics directly from cloud service, if you use clickhouse managed

## Usage
### Benchmark pre-configuration (optional)
If you want to use benching, you can try [one](https://github.com/VictoriaMetrics/prometheus-benchmark) from victoria metrics.
It is easy to configure. You just need to specify in the values.yaml file parameters for benching, ex:
```yaml
writeReplicas: 1
writeConcurrency: 10
targetsCount: 8000
scrapeInterval: 15s
queryInterval: 15s
```

And point it to carbon instance
```yaml
remoteStorages:
  # the name of the remote storage to test.
  # The name is added to remote_storage_name label at collected metrics
  vm:
    # writeURL should contain the url, which accepts Prometheus remote_write
    # protocol at the tested remote storage.
    # For example, the following urls may be used for testing VictoriaMetrics:
    # - http://<victoriametrics-addr>:8428/api/v1/write for single-node VictoriaMetrics
    # - http://<vminsert-addr>:8480/insert/0/prometheus/api/v1/write for cluster VictoriaMetrics
    writeURL: "http://clickhouse-longstorage-carbon-service.click-graphite.svc.cluster.local:2006" #Your url. Remains the same, if you do not change namespace in thus chart
```
If you use default namespace, and run benchmark in the same cluster, all the essential url's are already prefilled.

- Pull this repository locally, using git pull
- Cd to repository
- Edit values.yaml file or create your own CustomValues.yaml - file
- Configure template - files for your use case, define chart specification in templates folder
- Run: 

    ```bash
    helm -n click-graphite install -f CustomValues.yaml clickhouse-longstorage .
    ```

# Benchmark results
## Specifications
- cluster1 (data): 2 shard 2 hosts each for Replicated Tables
- cluster2 (front): 1 host for distributed tabels
- Every component has 2 CPUs and 4 GB RAM

## Test1
| Benchmark params   |             |
|--------------------|-------------|
| WriteReplicas      | 1           |
|     TargetCount    |     1000    |
|     Concurrency    |     8       |

| Ingest results |               |            |                    |                       |
|----------------|---------------|------------|--------------------|-----------------------|
|                |     CPU       |     RAM    |     Insert Rate    |     Failed queries    |
|     Shards     |     10-13%    |     25%    |     30-35k         |     0                 |
|     Front      |     16%       |     25%    |     120k           |     0                 |

| Select results |                                    |                         |                        |               |                                                        |                        |                        |               |
|----------------|------------------------------------|-------------------------|------------------------|---------------|--------------------------------------------------------|------------------------|------------------------|---------------|
|                |             PromQL query           |                         |                        |               |                                                        |                        |                        |               |
|                |     node_cpu_seconds_total[10h]    |                         |                        |               |     sum_over_time     (node_cpu_seconds_total[10h])    |                        |                        |               |
|                |     CPU                            |     RAM                 |     Series Returned    |     Time      |     CPU                                                |     RAM                |     Series Returned    |     Time      |
|     Shards     |     Increased to 20%               |     Increased to 30%    |     5524320            |     65 sec    |     No changes                                         |     No changes         |     48000              |     15 sec    |
|     Front      |     Increased to 20%               |     25%                 |                        |               |     No changes                                         |     No changes         |                        |               |

### Bench Metrics:
IngestRate - 116wr/s
The number of dropped data packets when sending them to CH - 0
Amounts of pending data at vmagent side, which isn't sent to remote storage yet - 0
Number of retries when sending data to remote storage - 0
99th percentile for the duration to push the collected data to the configured remote storage - 0.05 sec max


## Test2
| Benchmark params   |             |
|--------------------|-------------|
| WriteReplicas      | 1           |
|     TargetCount    |     8000    |
|     Concurrency    |     10      |

| Ingest results |               |                                |                       |
|----------------|---------------|------------|-----------------------|
|                |     CPU       |     RAM        |     Failed queries    |
|     Shards     |     up to 100% for large selects. AVG - 75%    |     2/4 - up to 50%. 2/4 - 30-35%                |     peaks to 5%                 |
|     Front      |     45%       |     35-37%                    |     peaks to 5%                 |

### Bench Metrics:
IngestRate - 420wr/s
The number of dropped data packets when sending them to CH - 0
Amounts of pending data at vmagent side, which isn't sent to remote storage yet - 0
Number of retries when sending data to remote storage - small jumps to 0.6
99th percentile for the duration to push the collected data to the configured remote storage - 1-1.7%

### Notes:
Heavy sql's consume all cpu
Long time for grafana graph draw
400k - is a limit for this setup