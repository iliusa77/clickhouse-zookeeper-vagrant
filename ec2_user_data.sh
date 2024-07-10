  #!/bin/bash
sudo bash -c "echo 'nameserver 8.8.8.8' >> /etc/resolv.conf"
sudo bash -c "echo 'nameserver 8.8.4.4' >> /etc/resolv.conf"
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
sudo yum install -y curl wget net-tools telnet
echo "${clickhouse-shard-0-private_ip} clickhouse-shard-0" >> /etc/hosts
echo "${clickhouse-shard-1-private_ip} clickhouse-shard-1" >> /etc/hosts
echo "${clickhouse-shard-2-private_ip} clickhouse-shard-2" >> /etc/hosts
sudo yum remove -y jdk
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
sudo bash -c "cat << EOF > /etc/profile.d/java_home.sh
jdk_version=\$(ls -al /usr/lib/jvm|grep \"^d\"|grep \"java\"|awk '{print\$NF}')
export JAVA_HOME=/usr/lib/jvm/\$jdk_version
EOF"

# zookeeper
sudo groupadd -r zookeeper
sudo useradd -c "ZooKeeper" -s /sbin/nologin -g zookeeper -r zookeeper
sudo mkdir /var/log/zookeeper
sudo mkdir /var/lib/zookeeper
chown zookeeper:zookeeper /var/lib/zookeeper
chown zookeeper:zookeeper /var/log/zookeeper
cd /tmp
wget https://dlcdn.apache.org/zookeeper/zookeeper-3.9.2/apache-zookeeper-3.9.2-bin.tar.gz
sudo tar -zxvf apache-zookeeper-3.9.2-bin.tar.gz -C /usr/local 
sudo ln -s /usr/local/apache-zookeeper-3.9.2-bin /usr/local/zookeeper
sudo chown -R zookeeper:zookeeper /usr/local/apache-zookeeper-3.9.2-bin
sudo chown zookeeper:zookeeper /usr/local/zookeeper
sudo mkdir /var/lib/zookeeper
sudo mkdir /var/log/zookeeper
sudo chown zookeeper:zookeeper /var/lib/zookeeper
sudo chown zookeeper:zookeeper /var/log/zookeeper
sudo bash -c " cat << EOF > /usr/local/zookeeper/conf/zoo.cfg
# The number of milliseconds of each tick
tickTime=2000

# The number of ticks that the initial
# synchronization phase can take
initLimit=10

# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=1

# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=/var/lib/zookeeper

# Directory to write the transaction log to the dataLogDir rather than the dataDir.
# This allows a dedicated log device to be used, and helps avoid competition between logging and snaphots.
dataLogDir=/var/lib/zookeeper

# the port at which the clients will connect
clientPort=2181

# the maximum number of client connections.
# increase this if you need to handle more clients
maxClientCnxns=10000

# The number of snapshots to retain in dataDir
autopurge.snapRetainCount=100
# Purge task interval in hours
# Set to "0" to disable auto purge feature
autopurge.purgeInterval=24
autopurge.snapRetainCount=3
#Service
server.0=clickhouse-shard-0:2888:3888
server.1=clickhouse-shard-1:2888:3888
server.2=clickhouse-shard-2:2888:3888
EOF"
sudo chown zookeeper:zookeeper /usr/local/zookeeper/conf/zoo.cfg
sudo mkdir /etc/zookeeper
sudo chown zookeeper:zookeeper /etc/zookeeper
sudo ln -s /usr/local/zookeeper/conf/zoo.cfg /etc/zookeeper/zoo.cfg
sudo chown zookeeper:zookeeper /etc/zookeeper/zoo.cfg

sudo bash -c "cat << EOF > /lib/systemd/system/zookeeper.service
[unit]
Description=zookeeper:3.9.2
After=network.target

[Service]
Type=forking
User=zookeeper
Group=zookeeper

WorkingDirectory=/usr/local/zookeeper

ExecStart=/usr/local/zookeeper/bin/zkServer.sh start
ExecStop=/usr/local/zookeeper/bin/zkServer.sh stop
ExecReload=/usr/local/zookeeper/bin/zkServer.sh restart

RestartSec=30
Restart=always

PrivateTmp=yes
PrivateDevices=yes

LimitCORE=infinity
LimitNOFILE=500000
[Install]
WantedBy=multi-user.target
Alias=zookeeper.service
EOF"
sudo systemctl restart zookeeper
sudo systemctl enable zookeeper

# clickhouse
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://packages.clickhouse.com/rpm/clickhouse.repo
sudo yum install -y clickhouse-server clickhouse-client
wget https://gist.githubusercontent.com/iliusa77/f7ad4bba2417a859eb222059642ff9b8/raw/1a974421b807e7bd1011cb1d8c6be3e849efe9df/clickhouse-server-config.xml
sudo bash -c "cp ./clickhouse-server-config.xml /etc/clickhouse-server/config.xml"
sudo systemctl restart clickhouse-server
sudo systemctl enable clickhouse-server