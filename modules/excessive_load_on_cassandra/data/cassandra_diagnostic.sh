

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