
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Excessive Load on Cassandra
---

Excessive load on Cassandra incident refers to a situation where there is an overload of requests or data processing on the Cassandra database management system. This can cause the system to slow down or even crash, resulting in service disruptions and downtime. This incident can occur due to various factors such as increased user traffic, inefficient queries, or hardware issues.

### Parameters
```shell
export CASSANDRA_NODE="PLACEHOLDER"

export KEYSPACE="PLACEHOLDER"

export KEYSPACE_NAME="PLACEHOLDER"

export TABLE_NAME="PLACEHOLDER"

export NEW_NODE_IP="PLACEHOLDER"

export NEW_NODE_NAME="PLACEHOLDER"

export CASSANDRA_NODE_IP="PLACEHOLDER"

export DATACENTER_NAME="PLACEHOLDER"
```

## Debug

### Check the number of connections to Cassandra
```shell
ssh ${CASSANDRA_NODE} "nodetool info | grep 'Native Transport'"
```

### Check the disk usage on the Cassandra nodes
```shell
ssh ${CASSANDRA_NODE} "df -h"
```

### Check the CPU usage on the Cassandra nodes
```shell
ssh ${CASSANDRA_NODE} "top -b -n 1 | grep Cpu"
```

### Check the read/write latencies on Cassandra
```shell
ssh ${CASSANDRA_NODE} "nodetool cfstats | grep -A 10 'Keyspace: ${KEYSPACE}'"
```

### Check the Cassandra system log
```shell
ssh ${CASSANDRA_NODE} "tail -n 100 /var/log/cassandra/system.log"
```

### Increased traffic on the application leading to a higher number of requests to the Cassandra database.
```shell


#!/bin/bash



# Set variables

KEYSPACE=${KEYSPACE_NAME}

TABLE=${TABLE_NAME}

DATE=$(date +"%Y-%m-%d_%H-%M-%S")

LOG_FILE=/var/log/cassandra/diagnostic-$DATE.log

THRESHOLD=100



# Log start of diagnostic process

echo "Starting diagnostic process at $(date)" >> $LOG_FILE



# Check for increased traffic on the application

REQUEST_COUNT=$(nodetool cfstats $KEYSPACE.$TABLE | grep "Read Count" | awk '{print $3}')

if [ "$REQUEST_COUNT" -gt "$THRESHOLD" ]; then

    echo "Increased traffic detected. Request count: $REQUEST_COUNT" >> $LOG_FILE



    # Check for slow queries

    SLOW_QUERIES=$(nodetool cfstats $KEYSPACE.$TABLE | grep "Mean Row" | awk '{print $4}')

    if [ "$SLOW_QUERIES" -gt "$THRESHOLD" ]; then

        echo "Slow queries detected. Mean row size: $SLOW_QUERIES" >> $LOG_FILE

    fi



    # Check for node health

    NODE_STATUS=$(nodetool status | grep "UN")

    if [ -z "$NODE_STATUS" ]; then

        echo "Node(s) down or not responding." >> $LOG_FILE

    else

        echo "All nodes healthy." >> $LOG_FILE

    fi

else

    echo "No increased traffic detected. Request count: $REQUEST_COUNT" >> $LOG_FILE

fi



# Log end of diagnostic process

echo "Diagnostic process completed at $(date)" >> $LOG_FILE


```

## Repair

### Scale up the Cassandra cluster by adding more nodes to handle the increased load.
```shell


#!/bin/bash



# Set variables for the new node to be added

NEW_NODE_IP=${NEW_NODE_IP}

NEW_NODE_NAME=${NEW_NODE_NAME}



# SSH into the existing Cassandra nodes to add the new node

ssh ${CASSANDRA_NODE_IP} "nodetool add ${NEW_NODE_IP}; echo '${NEW_NODE_NAME}' >> /etc/hosts"


# Wait for the new node to join the cluster

sleep 30



# Check the status of the new node

nodetool status | grep ${NEW_NODE_NAME}



# Verify that the cluster is balanced

nodetool status | grep -A 1 "Datacenter: ${DATACENTER_NAME}" | tail -n 1 | awk '{print $NF}'


```