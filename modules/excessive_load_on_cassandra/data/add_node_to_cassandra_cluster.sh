

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