#!/bin/bash
set -eo pipefail

# Start SSH
service ssh start

# Start ngrok with verbose logging
echo "Starting ngrok with full debug output..."
su - $USER -c "ngrok start --all --config=/home/$USER/.config/ngrok/ngrok.yml --log=stdout" > /var/log/ngrok.log 2>&1 &

# Wait for tunnel
echo "Waiting for tunnel to initialize..."
for i in {1..30}; do
    if grep -q "started tunnel" /var/log/ngrok.log; then
        break
    fi
    sleep 1
done

# Get tunnel URL (multiple methods)
NGROK_URL=$(grep -o "url=tcp://[^ ]*" /var/log/ngrok.log | cut -d'=' -f2 || true)

# Fallback to API method
if [ -z "$NGROK_URL" ]; then
    NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[] | select(.proto == "tcp") | .public_url' || true)
fi

if [ -z "$NGROK_URL" ]; then
    echo "ERROR: Failed to establish ngrok tunnel!"
    echo "Possible reasons:"
    echo "1. Invalid ngrok token"
    echo "2. Network connectivity issues"
    echo "3. Ngrok service outage"
    echo ""
    echo "Debug information:"
    cat /var/log/ngrok.log
    echo ""
    echo "Trying to get ngrok status..."
    su - $USER -c "ngrok config check"
    su - $USER -c "ngrok version"
    exit 1
fi

echo "=========================================="
echo "  SSH Tunnel Established Successfully!"
echo "=========================================="
echo "Connect using:"
echo "ssh $USER@$(echo $NGROK_URL | cut -d':' -f2 | sed 's/\/\///') -p $(echo $NGROK_URL | cut -d':' -f3)"
echo "Password: $PASSWORD"
echo ""
echo "Ngrok dashboard: http://localhost:4040"
echo "=========================================="

# Keep container running
tail -f /dev/null
