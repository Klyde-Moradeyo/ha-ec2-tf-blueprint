#!/bin/bash

set -e 

export WORKING_DIR="${WORKING_DIR}"
echo "WORKING_DIR=${WORKING_DIR}" > /etc/environment
echo "${WORKING_DIR}"
mkdir -p "${WORKING_DIR}"

export RDS_HOST="${RDS_HOST}"
echo "RDS_HOST=${RDS_HOST}" > /etc/environment
echo "${RDS_HOST}" > "${WORKING_DIR}/rds_host.txt"

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

# Clone the repository
git clone https://github.com/Klyde-Moradeyo/election-web-app.git $WORKING_DIR/election-web-app

echo "Creating .env file..."
{
    echo "DB_HOST=$DB_HOST"
    echo "DB_USERNAME=$DB_USERNAME"
    echo "DB_PASSWORD=$DB_PASSWORD"
} > $WORKING_DIR/election-web-app/.env

echo ".env file created successfully."

# Start APP
cd $WORKING_DIR/election-web-app && sudo docker-compose up --build  

echo "finished"



