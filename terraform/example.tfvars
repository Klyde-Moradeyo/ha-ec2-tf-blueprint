# name
name = "election-web-app"

# region
aws_region = "eu-west-2"

# Tags
project     = "election-web-app"
client      = "public"
owner       = "Klyde-Moradeyo"
namespace   = "terraform-template"
environment = "dev"

# Vpc
vpc_cidr = "10.0.0.0/16"

# Subnet
private_subnet_cidrs = [
  "10.0.30.0/24",
  "10.0.31.0/24",
  "10.0.32.0/24"
]
public_subnet_cidrs = [
  "10.0.33.0/24",
  "10.0.34.0/24",
  "10.0.35.0/24"
]

# EC2
ec2_ami      = "ami-004961349a19d7a8f"
ec2_type     = "t3.small"
ec2_userdata = <<-EOF
  #!/bin/bash

  set -e 

  WORKING_DIR="/home/ec2-user/server"
  mkdir -p $WORKING_DIR

  retry_command() {
      local max_attempts=15 
      local attempt=0
      local sleep_interval=30 # seconds between attempts
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
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose # create a symbolic link to docker-compose
  export PATH="/usr/local/bin:$PATH"

  sleep 5
  
  # Clone the repository
  git clone https://github.com/Klyde-Moradeyo/election-web-app.git $WORKING_DIR/election-web-app

  # Start APP
  cd $WORKING_DIR/election-web-app && sudo docker-compose up --build

  echo "finished"
EOF


