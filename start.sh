#!/bin/bash
set -eo pipefail

# Verify services
echo "=== System Verification ==="
echo "SSH status:" && service ssh status
echo "Ngrok version:" && su - $USER -c "ngrok version"
echo "Config check:" && su - $USER -c "ngrok config check"

# Start SSH
service ssh restart

# Start ngrok with full logging
echo "=== Starting Ngrok Tunnel ==="
su - $USER -c "ngrok start --all --config=/home/$USER/.config/ngrok/ngrok.yml --log=stdout" > /var/log/ngrok.log 2>&1 &

# Wait for tunnel with timeout
echo "Waiting for tunnel to establish..."
for i in {1..30}; do
    if grep -q "started tunnel" /var/log/ngrok.log; then
        echo "Tunnel established successfully"
        break
    fi
    sleep 1
done

# Get tunnel URL (multiple methods)
NGROK_URL=$( (grep -o "url=tcp://[^ ]*" /var/log/ngrok.log || curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[] | select(.proto == "tcp") | .public_url') | head -1 | cut -d'=' -f2)

if [ -z "$NGROK_URL" ]; then
    echo "=== ERROR: Tunnel Failed ==="
    echo "Ngrok Log:"
    cat /var/log/ngrok.log
    echo "Config File:"
    cat /home/$USER/.config/ngrok/ngrok.yml
    exit 1
fi

# Display connection info
echo "=== SSH Connection Details ==="
echo "Host: $(echo $NGROK_URL | cut -d':' -f2 | sed 's/\/\///')"
echo "Port: $(echo $NGROK_URL | cut -d':' -f3)"
echo "Username: $USER"
echo "Password: $PASSWORD"
echo "============================="

# Keep container running
tail -f /dev/null
