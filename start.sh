#!/bin/bash
# Start SSH silently
service ssh start > /dev/null 2>&1

# Persistent tunnel with connection logging
while true; do
  echo "=== Establishing Tunnel ==="
  ssh -o ExitOnForwardFailure=yes \
      -o ServerAliveInterval=60 \
      -o StrictHostKeyChecking=no \
      -R 80:localhost:22 \
      nokey@localhost.run
  
  # Sleep before reconnecting
  echo "=== Tunnel Disconnected - Retrying in 10s ==="
  sleep 10
done
