#!/bin/bash
set -eo pipefail

# Verify ngrok is installed
if ! command -v ngrok &> /dev/null; then
    echo "ERROR: ngrok binary not found!"
    exit 1
fi

# Verify config exists
if [ ! -f "/home/$USER/.config/ngrok/ngrok.yml" ]; then
    echo "ERROR: ngrok config file missing!"
    exit 1
fi

# Start SSH
service ssh start

# Start ngrok with logging
echo "Starting ngrok tunnel..."
su - $USER -c "ngrok start --all --config=/home/$USER/.config/ngrok/ngrok.yml --log=stdout" > /var/log/ngrok.log 2>&1 &

# Wait for tunnel establishment
echo "Waiting for tunnel to initialize..."
for i in {1..30}; do
    if grep -q "started tunnel" /var/log/ngrok.log; then
        break
    fi
    sleep 1
done

# Get tunnel URL
NGROK_URL=$(grep -o "url=tcp://[^ ]*" /var/log/ngrok.log | cut -d'=' -f2 || true)

if [ -z "$NGROK_URL" ]; then
    echo "ERROR: Failed to establish ngrok tunnel!"
    echo "Debug information:"
    cat /var/log/ngrok.log
    exit 1
fi

echo "===================================="
echo "SSH Connection Details:"
echo "Host: $(echo $NGROK_URL | cut -d':' -f2 | sed 's/\/\///')"
echo "Port: $(echo $NGROK_URL | cut -d':' -f3)"
echo "Username: $USER"
echo "Password: $PASSWORD"
echo "===================================="

# Keep container running
tail -f /dev/null
