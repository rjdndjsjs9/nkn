#!/bin/bash
set -eo pipefail

# Verify config exists and is valid
if ! su - $USER -c "ngrok config check"; then
    echo "ERROR: Invalid ngrok configuration"
    echo "=== Config File ==="
    cat /home/$USER/.config/ngrok/ngrok.yml
    exit 1
fi

# Start SSH
service ssh start

# Start ngrok with full logging
echo "Starting ngrok tunnel..."
su - $USER -c "ngrok start --all --config=/home/$USER/.config/ngrok/ngrok.yml --log=stdout" > /var/log/ngrok.log 2>&1 &

# Wait for tunnel
echo "Waiting for tunnel to establish..."
for i in {1..30}; do
    if grep -q "started tunnel" /var/log/ngrok.log; then
        echo "Tunnel established successfully"
        break
    fi
    sleep 1
done

# Get tunnel URL
NGROK_URL=$(grep -o "url=tcp://[^ ]*" /var/log/ngrok.log | cut -d'=' -f2 || true)

if [ -z "$NGROK_URL" ]; then
    echo "ERROR: Failed to establish ngrok tunnel!"
    echo "=== Ngrok Log ==="
    cat /var/log/ngrok.log
    exit 1
fi

echo "=========================================="
echo "SSH Connection Details:"
echo "Host: $(echo $NGROK_URL | cut -d':' -f2 | sed 's/\/\///')"
echo "Port: $(echo $NGROK_URL | cut -d':' -f3)"
echo "Username: $USER"
echo "Password: $PASSWORD"
echo "=========================================="

# Keep container running
tail -f /dev/null
