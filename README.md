# Ubuntu VPS with Ngrok Access

This Docker setup creates an Ubuntu-based VPS with SSH access through Ngrok tunneling.

## Prerequisites

- Docker installed
- Ngrok account with auth token
- Basic knowledge of SSH

## Setup Instructions

1. Clone this repository:
   ```bash
   git clone https://github.com/your-repo/ubuntu-vps-docker.git
   cd ubuntu-vps-docker
Build the Docker image:

bash
docker build -t ubuntu-vps \
  --build-arg NGROK_TOKEN="your_ngrok_token_here" \
  --build-arg VPS_PASSWORD="your_custom_password_here" .
Run the container:

bash
docker run -d --name my-vps ubuntu-vps
Get connection details:

bash
docker logs my-vps
Connecting to Your VPS
From the logs, note the Ngrok URL (format: tcp://0.tcp.ngrok.io:12345)

Connect using SSH:

bash
ssh vpsuser@0.tcp.ngrok.io -p 12345
When prompted, enter your custom password

Security Notes
Root login is disabled

Only the created user has access

Consider using SSH keys instead of password authentication

Regularly update your password and Ngrok token


## How to Use This Structure

1. Create a new directory and place all three files in it
2. Open terminal in this directory
3. Build the image with your credentials:
   ```bash
   docker build -t ubuntu-vps \
     --build-arg NGROK_TOKEN="your_actual_ngrok_token" \
     --build-arg VPS_PASSWORD="your_secure_password" .
Run the container:

bash
docker run -d --name my-vps -p 22:22 ubuntu-vps
Check the logs for connection details:

bash
docker logs my-vps
This structure provides a complete, self-documented solution for your Ubuntu VPS with Ngrok access.

