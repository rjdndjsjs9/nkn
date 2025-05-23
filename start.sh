#!/bin/bash
set -eo pipefail

# Start SSH service
service ssh start

# Start ngrok with Northflank-friendly logging
echo "Starting ngrok tunnel..."
su - $USER -c "ngrok start --all --config=/home/$USER/.config/ngrok/ngrok.yml" > /var/log/ngrok.log 2>&1 &

# Wait for tunnel establishment
echo "Waiting for tunnel to come up..."
for i in {1..30}; do
    if grep -q "started tunnel" /var/log/ngrok.log; then
        break
    fi
    sleep 1
done

# Get tunnel URL (Northflank-compatible method)
NGROK_URL=$(grep -o "url=tcp://[^ ]*" /var/log/ngrok.log | cut -d'=' -f2 || true)

if [ -z "$NGROK_URL" ]; then
    echo "ERROR: Failed to establish ngrok tunnel!"
    echo "Debug information:"
    cat /var/log/ngrok.log
    echo "Trying alternative method..."
    
    # Alternative check using ngrok API
    if curl -s http://localhost:4040/api/tunnels | jq -e '.tunnels[0].public_url' >/dev/null; then
        NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
    fi
fi

if [ -n "$NGROK_URL" ]; then
    echo "=========================================="
    echo "  Northflank VPS Deployment Ready"
    echo "=========================================="
    echo "SSH Connection Details:"
    echo "Host: $(echo $NGROK_URL | cut -d':' -f2 | sed 's/\/\///')"
    echo "Port: $(echo $NGROK_URL | cut -d':' -f3)"
    echo "Username: $USER"
    echo "Password: $PASSWORD"
    echo "=========================================="
    
    # Continuous health monitoring
    while true; do
        sleep 300
        if ! pgrep ngrok >/dev/null; then
            echo "Ngrok tunnel stopped, restarting..."
            su - $USER -c "ngrok start --all --config=/home/$USER/.config/ngrok/ngrok.yml" > /var/log/ngrok.log 2>&1 &
        fi
    done
else
    echo "FATAL: Could not establish ngrok connection after multiple attempts"
    exit 1
fi
