# sql
Contains sql - scripts for several purposes
- CreateGraphiteTables.sql - contains all sql - scripts you need to run to make your ClickHouse cluster work. Run them manually, or use a an sql-job, described in clickhouse-server and clickhouse-front-server deployment-files, in case you want to use local installation
- CreateTestMTtable.sql - example of creating simple Replicated and Distributed MergeTree table. In case you want to simply test this mechanism
- InsertTestRowGraphite.sql - example of insert to Distributed MergeTree table. Also for simple testing purposes