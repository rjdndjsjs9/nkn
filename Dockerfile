FROM ubuntu:22.04

# Set environment variables
ENV USER=morningstar
ENV VPS_PASSWORD=morningstar123
ENV NGROK_TOKEN=2xTln9L4XOhXExAqhRJo4KA6Qi6_4r8AJ2XibQ2tLdNQczzjt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    openssh-server \
    wget \
    curl \
    unzip \
    sudo \
    net-tools \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Create user
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$VPS_PASSWORD" | chpasswd && \
    usermod -aG sudo $USER

# Install ngrok with multiple fallback URLs
RUN for url in \
    "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz" \
    "https://dl.ngrok.com/ngrok-v3-stable-linux-amd64.tgz"; \
    do \
    if wget -q "$url" -O ngrok.tgz; then \
    tar xzf ngrok.tgz -C /usr/local/bin && \
    rm ngrok.tgz && \
    chmod +x /usr/local/bin/ngrok && \
    break; \
    fi; \
    done

# Configure ngrok with proper YAML format
RUN mkdir -p /home/$USER/.config/ngrok && \
    echo -e "version: \"2\"\nauthtoken: \"$NGROK_TOKEN\"\nregion: us\ntunnels:\n  ssh:\n    proto: tcp\n    addr: 22" > /home/$USER/.config/ngrok/ngrok.yml && \
    chown -R $USER:$USER /home/$USER/.config

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22
CMD ["/start.sh"]
