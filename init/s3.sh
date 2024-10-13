#!/bin/bash

# Load environment variables from the .env file
source /etc/localstack/init/ready.d/.env

# Function to check LocalStack health status
check_health() {
    echo "Checking LocalStack health..."
    for i in $(seq 1 $TRIES); do
        if curl -s $LOCALSTACK_API/_localstack/health | grep "\"s3\": \"available\"" > /dev/null; then
            echo "LocalStack is healthy. Proceeding..."
            return 0
        fi
        echo "LocalStack is not ready. Waiting... ($i/$TRIES)"
        sleep 5
    done
    echo "LocalStack failed to become healthy after $TRIES attempts."
    exit 1
}

# Function to create S3 bucket
create_s3_bucket() {
    echo "Creating S3 bucket(s): $BUCKET_NAMES"
    for BUCKET in ${BUCKET_NAMES//,/ }; do
        aws --endpoint-url=$LOCALSTACK_API s3api create-bucket --bucket $BUCKET --region us-east-1
        echo "Created bucket: $BUCKET"
    done
}

# Main execution
check_health
create_s3_bucket
