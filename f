#!/bin/bash

# Create topics for agent1
kafka-topics.sh --bootstrap-server localhost:9093 \
    --create --topic mm2-configs.agent1.internal \
    --partitions 1 --replication-factor 3 \
    --config cleanup.policy=compact

kafka-topics.sh --bootstrap-server localhost:9093 \
    --create --topic mm2-offsets.agent1.internal \
    --partitions 25 --replication-factor 3 \
    --config cleanup.policy=compact

kafka-topics.sh --bootstrap-server localhost:9093 \
    --create --topic mm2-status.agent1.internal \
    --partitions 5 --replication-factor 3 \
    --config cleanup.policy=compact

kafka-topics.sh --bootstrap-server localhost:9093 \
    --create --topic heartbeats.agent1 \
    --partitions 1 --replication-factor 3 \
    --config cleanup.policy=compact

# Create topics for agent2
kafka-topics.sh --bootstrap-server localhost:9093 \
    --create --topic mm2-configs.agent2.internal \
    --partitions 1 --replication-factor 3 \
    --config cleanup.policy=compact

kafka-topics.sh --bootstrap-server localhost:9093 \
    --create --topic mm2-offsets.agent2.internal \
    --partitions 25 --replication-factor 3 \
    --config cleanup.policy=compact

kafka-topics.sh --bootstrap-server localhost:9093 \
    --create --topic mm2-status.agent2.internal \
    --partitions 5 --replication-factor 3 \
    --config cleanup.policy=compact

kafka-topics.sh --bootstrap-server localhost:9093 \
    --create --topic heartbeats.agent2 \
    --partitions 1 --replication-factor 3 \
    --config cleanup.policy=compact

# Set ACLs for user1 (agent1)
kafka-acls.sh --bootstrap-server localhost:9093 \
    --command-config admin.properties \
    --add \
    --allow-principal User:user1 \
    --operation Read,Write,Create,Describe,DescribeConfigs \
    --topic "mm2-configs.agent1.internal"

kafka-acls.sh --bootstrap-server localhost:9093 \
    --command-config admin.properties \
    --add \
    --allow-principal User:user1 \
    --operation Read,Write,Create,Describe,DescribeConfigs \
    --topic "mm2-offsets.agent1.internal"

kafka-acls.sh --bootstrap-server localhost:9093 \
    --command-config admin.properties \
    --add \
    --allow-principal User:user1 \
    --operation Read,Write,Create,Describe,DescribeConfigs \
    --topic "mm2-status.agent1.internal"

kafka-acls.sh --bootstrap-server localhost:9093 \
    --command-config admin.properties \
    --add \
    --allow-principal User:user1 \
    --operation Read,Write,Create,Describe,DescribeConfigs \
    --topic "heartbeats.agent1"

# Add group ACLs for user1
kafka-acls.sh --bootstrap-server localhost:9093 \
    --command-config admin.properties \
    --add \
    --allow-principal User:user1 \
    --operation Read,Describe \
    --group "*"
