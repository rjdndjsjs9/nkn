#!/bin/bash
set -euo pipefail

# Initialize logging
mkdir -p /var/log/vps
exec > >(tee -a /var/log/vps/startup.log)
exec 2>&1

echo "[$(date)] Starting VPS initialization..."

# Start SSH service
echo "Starting SSH server..."
service ssh start

# Verify SSH is running
if ! pgrep sshd >/dev/null; then
    echo "ERROR: SSH server failed to start!"
    exit 1
fi

# Start ngrok tunnel
echo "Starting ngrok tunnel..."
su - $USER -c "ngrok tcp 22 --log=stdout --config=/home/$USER/.ngrok2/ngrok.yml" > /var/log/ngrok.log 2>&1 &

# Wait for ngrok to initialize
echo "Waiting for ngrok to initialize..."
sleep 5

# Get ngrok URL
NGROK_URL=$(grep -o "url=tcp://[^ ]*" /var/log/ngrok.log | cut -d'=' -f2 || true)

if [ -z "$NGROK_URL" ]; then
    echo "WARNING: Failed to get ngrok URL"
else
    echo "============================================"
    echo "Ngrok tunnel established!"
    echo "Connect using:"
    echo "ssh $USER@$(echo $NGROK_URL | cut -d':' -f2 | sed 's/\/\///') -p $(echo $NGROK_URL | cut -d':' -f3)"
    echo "Password: $VPS_PASSWORD"
    echo "============================================"
fi

# Continuous health monitoring
echo "Starting health monitoring..."
while true; do
    # Verify SSH is still running
    if ! pgrep sshd >/dev/null; then
        echo "ERROR: SSH server stopped unexpectedly!"
        service ssh start
    fi
    
    # Verify ngrok is still running if URL was obtained
    if [ -n "$NGROK_URL" ] && ! pgrep ngrok >/dev/null; then
        echo "WARNING: ngrok tunnel stopped, restarting..."
        su - $USER -c "ngrok tcp 22 --log=stdout --config=/home/$USER/.ngrok2/ngrok.yml" > /var/log/ngrok.log 2>&1 &
        sleep 5
        NGROK_URL=$(grep -o "url=tcp://[^ ]*" /var/log/ngrok.log | cut -d'=' -f2 || true)
    fi
    
    sleep 30
done
