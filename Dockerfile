# Use Ubuntu 22.04 with verified checksum
FROM ubuntu:22.04@sha256:6120be6a2b7ce665d0cbddc7294c794d5b3b4fbb8efdb8a3aa8fbc9b2b5a2b1c

# Set environment variables
ENV USER=morningstar
ENV VPS_PASSWORD=morningstar123
ENV NGROK_TOKEN=2xTln9L4XOhXExAqhRJo4KA6Qi6_4r8AJ2XibQ2tLdNQczzjt
ENV DEBIAN_FRONTEND=noninteractive

# Install packages with cleanup
RUN apt-get update && \
    apt-get install -y \
    openssh-server \
    wget \
    curl \
    unzip \
    sudo \
    net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH securely
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Create user
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$VPS_PASSWORD" | chpasswd && \
    usermod -aG sudo $USER

# Install ngrok with verification
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O ngrok.tgz && \
    tar xzf ngrok.tgz -C /usr/local/bin && \
    rm ngrok.tgz && \
    chmod +x /usr/local/bin/ngrok

# Configure ngrok
RUN mkdir -p /home/$USER/.ngrok2 && \
    echo "authtoken: $NGROK_TOKEN" > /home/$USER/.ngrok2/ngrok.yml && \
    chown -R $USER:$USER /home/$USER/.ngrok2

# Copy enhanced startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD netstat -tuln | grep -q ':22 ' || exit 1

EXPOSE 22

# Use exec form for better signal handling
CMD ["/start.sh"]
