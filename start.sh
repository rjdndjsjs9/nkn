#!/bin/bash
set -euo pipefail

# Initialize logging
exec > >(tee /var/log/startup.log)
exec 2>&1

echo "[$(date)] Starting VPS initialization..."

# Start SSH
echo "Starting SSH server..."
service ssh start

# Verify SSH
if ! pgrep sshd >/dev/null; then
    echo "ERROR: SSH failed to start!"
    exit 1
fi

# Start ngrok with proper config path
echo "Starting ngrok tunnel..."
su - $USER -c "ngrok start --all --config=/home/$USER/.config/ngrok/ngrok.yml" > /var/log/ngrok.log 2>&1 &

# Wait for tunnel with timeout
echo "Waiting for tunnel establishment..."
for i in {1..30}; do
    if curl -s http://localhost:4040/api/tunnels | jq -e '.tunnels[] | select(.proto == "tcp")' >/dev/null; then
        NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[] | select(.proto == "tcp") | .public_url')
        break
    fi
    sleep 1
done

# Display connection info
if [ -n "$NGROK_URL" ]; then
    echo "========================================"
    echo " Ngrok Tunnel Established!"
    echo " URL: $NGROK_URL"
    echo " Connect using:"
    echo " ssh $USER@$(echo $NGROK_URL | cut -d':' -f2 | sed 's/\/\///') -p $(echo $NGROK_URL | cut -d':' -f3)"
    echo " Password: $VPS_PASSWORD"
    echo "========================================"
else
    echo "ERROR: Failed to establish ngrok tunnel!"
    echo "Possible reasons:"
    echo "1. Invalid ngrok token"
    echo "2. Network connectivity issues"
    echo "3. Ngrok service outage"
    echo ""
    echo "Debug information:"
    cat /var/log/ngrok.log
    exit 1
fi

# Keep container running
tail -f /dev/null
