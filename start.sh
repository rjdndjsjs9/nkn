#!/bin/bash
set -euo pipefail

# Initialize logging
mkdir -p /var/log/vps
exec > >(tee -a /var/log/vps/startup.log)
exec 2>&1

echo "[$(date)] Starting VPS initialization..."

# Start SSH service
echo "Starting SSH server..."
service ssh restart

# Verify SSH is running
if ! pgrep sshd >/dev/null; then
    echo "ERROR: SSH server failed to start!"
    service ssh status
    exit 1
fi

# Start ngrok tunnel
echo "Starting ngrok tunnel..."
su - $USER -c "ngrok tcp 22 --log=stdout --config=/home/$USER/.ngrok2/ngrok.yml" > /var/log/ngrok.log 2>&1 &

# Wait for ngrok to initialize
echo "Waiting for ngrok to initialize..."
for i in {1..10}; do
    if grep -q "started tunnel" /var/log/ngrok.log; then
        break
    fi
    sleep 3
done

# Get ngrok URL
NGROK_URL=$(grep -o "url=tcp://[^ ]*" /var/log/ngrok.log | cut -d'=' -f2 || true)

if [ -z "$NGROK_URL" ]; then
    echo "ERROR: Failed to establish ngrok tunnel!"
    echo "Ngrok log:"
    cat /var/log/ngrok.log
else
    echo "============================================"
    echo "Ngrok tunnel established!"
    echo "Connect using:"
    echo "ssh $USER@$(echo $NGROK_URL | cut -d':' -f2 | sed 's/\/\///') -p $(echo $NGROK_URL | cut -d':' -f3)"
    echo "Password: $VPS_PASSWORD"
    echo "============================================"
fi

# Keep container running
tail -f /dev/null
