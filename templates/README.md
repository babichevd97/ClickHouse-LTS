# templates
Contains yaml - manifests for chart deployment
- carbon-clickhouseExample.yaml - carbon - component (ingestion)
- clickhouse-front-server.yaml - ClickHouse front-server for local installation
- clickhouse-server.yaml - ClickHouse one-node server configuration for local installation
- grafana-server.yaml - grafana server configuration for local installation
- graphite-clickhouseExample.yaml - graphite - component (reading data)
- node-exporter.yaml - basic node-exporter deployment, that scrapes your local data
- prometheus-deployment.yaml - prometheus deployment
- zookeeper.yaml - zookeeper.yaml

## configExample.xml
Example of keeping your ClickHouse connections in a single file to easily connect via clickhouse-client

## values.yaml
Main chart file with parameters. Should be filled for your needs

## zookeeperExample.xml
Example of zookeper configuration

## ext-clusters-example.xml
Example of cluster info-file to be filled, in case you are using your own CH configuration

Clickhouse need to upload it while starting to get up-to-date information about existing clusters and shards/replica inside i
**It is also very important**, that if you are using o separated cluster (front), that contacts another cluster (for example, distributed tables pointing to another cluster with replicated table), all clusters should be specified on the front - cluster

## prometheusYCMetrics.yaml
Example of file configuration to collect performance metrics directly from cloud service, if you use managed clickhouse
In our example we use metrics from Yandex Cloud