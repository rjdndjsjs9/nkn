FROM ubuntu:22.04

ENV USER=morningstar
ENV VPS_PASSWORD=morningstar123
ENV NGROK_TOKEN=2xTln9L4XOhXExAqhRJo4KA6Qi6_4r8AJ2XibQ2tLdNQczzjt

RUN apt-get update && apt-get install -y \
    openssh-server \
    wget \
    curl \
    sudo

# Create user
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$VPS_PASSWORD" | chpasswd && \
    usermod -aG sudo $USER

# Install ngrok
RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz && \
    tar xvzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin && \
    rm ngrok-v3-stable-linux-amd64.tgz && \
    chmod +x /usr/local/bin/ngrok

# Configure ngrok
RUN mkdir -p /home/$USER/.config/ngrok && \
    echo -e "version: \"2\"\nauthtoken: \"$NGROK_TOKEN\"\nregion: us\ntunnels:\n  ssh:\n    proto: tcp\n    addr: 22" > /home/$USER/.config/ngrok/ngrok.yml && \
    chown -R $USER:$USER /home/$USER/.config

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
