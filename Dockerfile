FROM ubuntu:22.04

# Set environment variables
ENV USER=morningstar
ENV PASSWORD=morningstar123
ARG NGROK_TOKEN

# Install dependencies
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
        openssh-server \
        wget \
        unzip \
        curl \
        jq \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir -p /run/sshd && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Create user
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USER

# Install ngrok
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O ngrok.tgz && \
    tar xzf ngrok.tgz -C /usr/local/bin && \
    rm ngrok.tgz && \
    chmod +x /usr/local/bin/ngrok

# Create validated ngrok config
RUN mkdir -p /home/$USER/.config/ngrok && \
    printf "version: \"2\"\nauthtoken: \"%s\"\nregion: us\ntunnels:\n  ssh:\n    proto: tcp\n    addr: 22\n" "$NGROK_TOKEN" > /home/$USER/.config/ngrok/ngrok.yml && \
    chown -R $USER:$USER /home/$USER/.config && \
    su - $USER -c "ngrok config check"

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22
CMD ["/start.sh"]
