This repository contains Clickhouse cluster in 3 nodes with Zookeeper deployed in 3 Vagrant VMs or in EC2 instances

### Versions
- Operating system: Linux CentOS 8
- Java: java-1.8.0
- Zookeeper: 3.9.2
- Clickhouse server: 24.6.2.17
- Clickhouse client: 24.6.2.17

Clickhouse config source - https://gist.githubusercontent.com/iliusa77/f7ad4bba2417a859eb222059642ff9b8/raw/6fc2055420330a3d81e8ce613e735fe34e79dee1/clickhouse-server-config.xml


## Vagrant
Run cluster deploy
```
vagrant up
```

Enter to first VM via SSH
```
vagrant ssh vm1
```

Check Zookeeper status
```
/usr/local/zookeeper/bin/zkServer.sh status
```

Check Zookeeper cli
```
/usr/local/zookeeper/bin/zkCli.sh -server clickhouse-shard-1:2181
/usr/local/zookeeper/bin/zkCli.sh -server clickhouse-shard-2:2181
/usr/local/zookeeper/bin/zkCli.sh -server clickhouse-shard-3:2181
```

Check Zookeeper accessibility by port in all nodes
```
telnet clickhouse-shard-1 2181
Trying 127.0.1.1...
Connected to clickhouse-shard-1.
Escape character is '^]'.
quit

telnet clickhouse-shard-2 2181
Trying 192.168.56.11...
Connected to clickhouse-shard-2.
Escape character is '^]'.
quit

telnet clickhouse-shard-3 2181
Trying 192.168.56.12...
Connected to clickhouse-shard-3.
Escape character is '^]'.
quit
```

Check Clickhouse client connections
```
[root@clickhouse-shard-1 ~]# clickhouse-client
ClickHouse client version 24.6.2.17 (official build).
Connecting to localhost:9000 as user default.
Connected to ClickHouse server version 24.6.2.

Warnings:
 * Linux transparent hugepages are set to "always". Check /sys/kernel/mm/transparent_hugepage/enabled
 * Linux threads max count is too low. Check /proc/sys/kernel/threads-max
 * Available memory at server startup is too low (2GiB).
 * Maximum number of threads is lower than 30000. There could be problems with handling a lot of simultaneous queries.

clickhouse-shard-1 :)

[vagrant@clickhouse-shard-2 ~]$ clickhouse-client
ClickHouse client version 24.6.2.17 (official build).
Connecting to localhost:9000 as user default.
Connected to ClickHouse server version 24.6.2.

Warnings:
 * Linux transparent hugepages are set to "always". Check /sys/kernel/mm/transparent_hugepage/enabled
 * Linux threads max count is too low. Check /proc/sys/kernel/threads-max
 * Available memory at server startup is too low (2GiB).
 * Maximum number of threads is lower than 30000. There could be problems with handling a lot of simultaneous queries.

clickhouse-shard-2 :)

[vagrant@clickhouse-shard-3 ~]$ clickhouse-client
ClickHouse client version 24.6.2.17 (official build).
Connecting to localhost:9000 as user default.
Connected to ClickHouse server version 24.6.2.

Warnings:
 * Linux transparent hugepages are set to "always". Check /sys/kernel/mm/transparent_hugepage/enabled
 * Linux threads max count is too low. Check /proc/sys/kernel/threads-max
 * Available memory at server startup is too low (2GiB).
 * Maximum number of threads is lower than 30000. There could be problems with handling a lot of simultaneous queries.

clickhouse-shard-3 :)
```

Let's create a table in the default database using the ReplicatedMergeTree mechanism containing the data
```
clickhouse-shard-1 :) CREATE TABLE warehouse_local_replicated ON CLUSTER 'default'
(
 warehouse_id Int64,
 product_id  Int64,
 avl_qty  Int64
)
Engine=ReplicatedMergeTree('/clickhouse/tables/{layer}-{shard}/warehouse_local_replicated', '{replica}')
PARTITION BY warehouse_id
ORDER BY product_id;
```


TROUBLESHOOTING
- case 1
```
CREATE TABLE warehouse_local_replicated ON CLUSTER 'default'
(
 warehouse_id Int64,
 product_id  Int64,
 avl_qty  Int64
)
Engine=ReplicatedMergeTree('/clickhouse/tables/{layer}-{shard}/warehouse_local_replicated', '{replica}')
PARTITION BY warehouse_id
ORDER BY product_id;

CREATE TABLE warehouse_local_replicated ON CLUSTER default
(
    `warehouse_id` Int64,
    `product_id` Int64,
    `avl_qty` Int64
)
ENGINE = ReplicatedMergeTree('/clickhouse/tables/{layer}-{shard}/warehouse_local_replicated', '{replica}')
PARTITION BY warehouse_id
ORDER BY product_id

Query id: b6f56d8e-dbd8-4c36-8876-63edb77e2181


Elapsed: 3.448 sec. 

Received exception from server (version 24.6.2):
Code: 999. DB::Exception: Received from localhost:9000. Coordination::Exception. Coordination::Exception: All connection tries failed while connecting to ZooKeeper. nodes: 192.168.56.12:2181, 192.168.56.11:2181, 127.0.1.1:2181
Poco::Exception. Code: 1000, e.code() = 113, Net Exception: No route to host (version 24.6.2.17 (official build)), 192.168.56.12:2181
Code: 33. DB::Exception: Cannot read all data. Bytes read: 0. Bytes expected: 4.: while receiving handshake from ZooKeeper. (CANNOT_READ_ALL_DATA) (version 24.6.2.17 (official build)), 192.168.56.11:2181
Code: 33. DB::Exception: Cannot read all data. Bytes read: 0. Bytes expected: 4.: while receiving handshake from ZooKeeper. (CANNOT_READ_ALL_DATA) (version 24.6.2.17 (official build)), 127.0.1.1:2181
Poco::Exception. Code: 1000, e.code() = 0, Timeout: connect timed out: 192.168.56.12:2181 (version 24.6.2.17 (official build)), 192.168.56.12:2181
Code: 33. DB::Exception: Cannot read all data. Bytes read: 0. Bytes expected: 4.: while receiving handshake from ZooKeeper. (CANNOT_READ_ALL_DATA) (version 24.6.2.17 (official build)), 192.168.56.11:2181
Code: 33. DB::Exception: Cannot read all data. Bytes read: 0. Bytes expected: 4.: while receiving handshake from ZooKeeper. (CANNOT_READ_ALL_DATA) (version 24.6.2.17 (official build)), 127.0.1.1:2181
Poco::Exception. Code: 1000, e.code() = 0, Timeout: connect timed out: 192.168.56.12:2181 (version 24.6.2.17 (official build)), 192.168.56.12:2181
Code: 33. DB::Exception: Cannot read all data. Bytes read: 0. Bytes expected: 4.: while receiving handshake from ZooKeeper. (CANNOT_READ_ALL_DATA) (version 24.6.2.17 (official build)), 192.168.56.11:2181
Code: 33. DB::Exception: Cannot read all data. Bytes read: 0. Bytes expected: 4.: while receiving handshake from ZooKeeper. (CANNOT_READ_ALL_DATA) (version 24.6.2.17 (official build)), 127.0.1.1:2181
. (KEEPER_EXCEPTION)

```

## EC2 (Terraform)

### Create S3 bucket for tfstate and DynamoDB table with LockID Partition key for locks Terraform execution
get S3 bucket name and DynamoDB table name from `providers.tf`
```
  backend "s3" {
    bucket         = "clickhouse-ec2-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "clickhouse-ec2-terraform"
  }
```

### Generate SSH pair
```
ssh-keygen -t rsa -b 4096 -f ./clickhouse-ssh-key
chmod 400 clickhouse-ssh-key
```

### Update Terraform variables
Define you own values in `vars.tf`
- put clickhouse-ssh-key.pub content in public_key
- env
- region

and so on ...

### Terraform init/plan/apply
```
terraform init

terraform plan

terraform apply -auto-approve
```