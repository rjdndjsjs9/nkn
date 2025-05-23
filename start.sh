#!/bin/bash
set -eo pipefail

# Verify ngrok installation
if ! command -v ngrok >/dev/null 2>&1; then
    echo "ERROR: ngrok binary not found!"
    exit 1
fi

# Start SSH
service ssh start

# Start ngrok with full logging
echo "Starting ngrok tunnel with debug output..."
su - $USER -c "ngrok start --all --config=/home/$USER/.config/ngrok/ngrok.yml --log=stdout" > /var/log/ngrok.log 2>&1 &

# Wait for tunnel initialization
echo "Waiting for tunnel to establish..."
for i in {1..30}; do
    if grep -q "started tunnel" /var/log/ngrok.log; then
        echo "Tunnel established successfully"
        break
    fi
    sleep 1
done

# Get tunnel URL with multiple fallback methods
NGROK_URL=$(grep -o "url=tcp://[^ ]*" /var/log/ngrok.log | cut -d'=' -f2 || true)
[ -z "$NGROK_URL" ] && NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[] | select(.proto == "tcp") | .public_url' || true)

if [ -z "$NGROK_URL" ]; then
    echo "ERROR: Failed to establish ngrok tunnel!"
    echo "=== Ngrok Log ==="
    cat /var/log/ngrok.log
    echo "=== Config Check ==="
    su - $USER -c "ngrok config check"
    echo "=== Version Info ==="
    su - $USER -c "ngrok version"
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
