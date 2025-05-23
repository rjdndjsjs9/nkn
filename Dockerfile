# Use official Ubuntu 22.04 image (without pinned SHA256)
FROM ubuntu:22.04

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
    sed -i 's/#PermitRootLogin prohibit-ssh/PermitRootLogin no/' /etc/ssh/sshd_config && \
    echo "AllowUsers $USER" >> /etc/ssh/sshd_config

# Create user
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$VPS_PASSWORD" | chpasswd && \
    usermod -aG sudo $USER && \
    echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USER

# Install ngrok with fallback URL
RUN { \
    wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O ngrok.tgz || \
    wget -q https://dl.ngrok.com/ngrok-v3-stable-linux-amd64.tgz -O ngrok.tgz; \
    } && \
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

EXPOSE 22

CMD ["/start.sh"]
