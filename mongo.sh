#!/bin/bash

# Specify Mongo version (default: latest)
MONGO_VERSION="mongo:latest"

# Generate a random host port for mapping
HOST_PORT=$(shuf -i 28000-32767 -n 1)

# Create a unique container name
CONTAINER_NAME="mongo-$(uuidgen)"

# Use /root/mongo/ as the data volume
DATA_VOLUME="-v /root/mongo:/data/db"

# Generate random username and password
MONGO_INITDB_ROOT_USERNAME=$(uuidgen | head -c 12)
MONGO_INITDB_ROOT_PASSWORD=$(uuidgen | head -c 12)

# Run the container with authentication enabled
docker run -d \
    --name $CONTAINER_NAME \
    -p $HOST_PORT:27017 \
    $DATA_VOLUME \
    -e MONGO_INITDB_ROOT_USERNAME=$MONGO_INITDB_ROOT_USERNAME \
    -e MONGO_INITDB_ROOT_PASSWORD=$MONGO_INITDB_ROOT_PASSWORD \
    $MONGO_VERSION

# Wait for container to start (adjust timeout if needed)
sleep 5

# Check if MongoDB is running
if ! docker ps | grep $CONTAINER_NAME &> /dev/null; then
    echo "Failed to start MongoDB container!"
    exit 1
fi

# Fetch public IP address
REMOTE_HOST=$(curl -s ifconfig.me)

# Construct remote connection string (with credentials)
CONNECTION_STRING="mongodb://$MONGO_INITDB_ROOT_USERNAME:$MONGO_INITDB_ROOT_PASSWORD@$REMOTE_HOST:$HOST_PORT"

echo "MongoDB connection string:"
echo "$CONNECTION_STRING"
