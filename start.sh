#!/bin/bash

service ssh start

su - $USER -c "ngrok tcp 22 --log=stdout > /var/log/ngrok.log &"

sleep 5
NGROK_URL=$(grep -o "url=tcp://[^ ]*" /var/log/ngrok.log | cut -d'=' -f2)

if [ -z "$NGROK_URL" ]; then
    echo "Failed to get Ngrok URL"
    exit 1
fi

echo "============================================"
echo "VPS is ready!"
echo "Connect using:"
echo "ssh $USER@$(echo $NGROK_URL | cut -d':' -f2 | sed 's/\/\///') -p $(echo $NGROK_URL | cut -d':' -f3)"
echo "Password: $VPS_PASSWORD"
echo "============================================"

tail -f /dev/null
