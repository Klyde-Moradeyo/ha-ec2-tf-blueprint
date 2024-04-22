#!/bin/bash

set -e 

# Set Env Vars
export WORKING_DIR="${WORKING_DIR}"
export RDS_HOST="${RDS_HOST}"
export DB_USERNAME="${DB_USERNAME}"
export DB_PASSWORD="${DB_PASSWORD}"
export RAILS_ENV="${RAILS_ENV}"

echo "WORKING_DIR=${WORKING_DIR}" > /etc/environment
echo "DB_HOST=${DB_HOST}" > /etc/environment
echo "DB_USERNAME=${DB_USERNAME}" > /etc/environment
echo "DB_PASSWORD=${DB_PASSWORD}" > /etc/environment
echo "RAILS_ENV=${RAILS_ENV}" > /etc/environment

GIT_URL="https://github.com/Klyde-Moradeyo/election-web-app.git"
GIT_BRANCH="aws-ha-ec2-tf-blueprint"

# Install Dependencies
retry_command() {
    local max_attempts=15 
    local attempt=0
    local sleep_interval=30
    local command="$@"

    echo "Executing command: $command"
    while [ $attempt -lt $max_attempts ]; do
        let attempt+=1
        if eval "$command"; then
            echo "Command succeeded: $command"
            return 0
        else
            echo "Attempt $attempt of $max_attempts failed for command: $command, retrying in $sleep_interval seconds..."
            sleep $sleep_interval
        fi
    done

    echo "Command failed after $max_attempts attempts: $command"
    exit 1
}

retry_command "sudo yum update -y"
retry_command "sudo yum install -y lsof ca-certificates curl gnupg2 unzip zip bc rsync wget git jq"

# Ensure git is available
until git --version 2>/dev/null; do
    echo "Waiting for git to become available..."
    sleep 2
done 

# Install Docker
retry_command "sudo amazon-linux-extras install docker -y"
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
export PATH="/usr/local/bin:$PATH"

sleep 5

# Prepare Application
APP_DIR="{$WORKING_DIR}/election-web-app"
mkdir -p "${WORKING_DIR}"

# Clone the repository
git clone -b $GIT_BRANCH --single-branch $GIT_URL $APP_DIR

# Generate Election Web App env file
echo "Creating .env file..."
{
    echo "DB_HOST=$DB_HOST"
    echo "DB_USERNAME=$DB_USERNAME"
    echo "DB_PASSWORD=$DB_PASSWORD"
    echo "RAILS_LOG_TO_STDOUT=true"
    echo "RAILS_ENV=production"
} > $APP_DIR/.env

echo ".env file created successfully."

# Start APP
cd $APP_DIR && sudo docker-compose up -d 

echo "Started Election Web App Containers"
echo "SUCCESS"



