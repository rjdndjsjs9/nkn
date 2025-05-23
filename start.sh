#!/bin/bash

# Start SSH
service ssh start

# Start ngrok in foreground with verbose logging
echo "Starting ngrok with verbose logging..."
su - $USER -c "ngrok start --all --config=/home/$USER/.config/ngrok/ngrok.yml --log=stdout" 2>&1 | tee /var/log/ngrok.log &

# Wait and show tunnel info
sleep 5
echo "=== Ngrok Log ==="
cat /var/log/ngrok.log
echo "================="

# Show active tunnels
echo "Checking tunnels..."
curl -s http://localhost:4040/api/tunnels | jq .

# Keep container running
tail -f /dev/null
