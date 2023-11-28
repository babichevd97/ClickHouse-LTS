CREATE OR REPLACE TABLE graphite ON CLUSTER prom_cluster (
  Path String,
  Value Float64,
  Time UInt32,
  Date Date,
  Timestamp UInt32
) ENGINE = ReplicatedGraphiteMergeTree('/clickhouse/tables/{shard}/default.graphite', '{replica}', 'carbon_rollup')
PARTITION BY toYYYYMM(Date)
ORDER BY (Path, Time);

CREATE OR REPLACE TABLE graphite_index ON CLUSTER prom_cluster (
  Date Date,
  Level UInt32,
  Path String,
  Version UInt32
) ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/default.graphite_index', '{replica}', Version)
PARTITION BY toYYYYMM(Date)
ORDER BY (Level, Path, Date);

CREATE OR REPLACE TABLE graphite_tagged ON CLUSTER prom_cluster (
  Date Date,
  Tag1 String,
  Path String,
  Tags Array(String),
  Version UInt32
) ENGINE = ReplicatedReplacingMergeTree('/clickhouse/tables/{shard}/default.graphite_tagged', '{replica}', Version)
PARTITION BY toYYYYMM(Date)
ORDER BY (Tag1, Path, Date);

---------

CREATE OR REPLACE TABLE distributed_graphite ON CLUSTER 'click-front'
--AS graphite    -- формат из определенной таблицы
(
  Path String,
  Value Float64,
  Time UInt32,
  Date Date,
  Timestamp UInt32
)
ENGINE = Distributed('prom_cluster', currentDatabase(), graphite, rand());

CREATE OR REPLACE TABLE distributed_graphite_index ON CLUSTER 'click-front'
--AS graphite_index   -- формат из определенной таблицы
(
  Date Date,
  Level UInt32,
  Path String,
  Version UInt32
)
ENGINE = Distributed('prom_cluster', currentDatabase(), graphite_index, rand());

CREATE OR REPLACE TABLE distributed_graphite_tagged ON CLUSTER 'click-front'
--AS graphite_tagged    -- формат из определенной таблицы
(
  Date Date,
  Tag1 String,
  Path String,
  Tags Array(String),
  Version UInt32
)
ENGINE = Distributed('prom_cluster', currentDatabase(), graphite_tagged, rand());
