FROM ubuntu:22.04

# Set environment variables
ENV USER=morningstar
ENV PASSWORD=morningstar123
ARG NGROK_TOKEN

# Install dependencies with proper cleanup
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

# Configure SSH securely
RUN mkdir -p /run/sshd && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Create user
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USER

# Install ngrok with multiple fallback methods
RUN set -e; \
    echo "Attempting ngrok installation..."; \
    if wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O ngrok.tgz; then \
        echo "Download successful, extracting..."; \
        tar xzf ngrok.tgz -C /usr/local/bin && \
        rm ngrok.tgz && \
        chmod +x /usr/local/bin/ngrok; \
    else \
        echo "Primary download failed, trying alternative..."; \
        wget -q https://dl.ngrok.com/ngrok-v3-stable-linux-amd64.tgz -O ngrok.tgz && \
        tar xzf ngrok.tgz -C /usr/local/bin && \
        rm ngrok.tgz && \
        chmod +x /usr/local/bin/ngrok; \
    fi; \
    echo "Verifying installation..."; \
    if ! ngrok version; then \
        echo "Ngrok verification failed!"; \
        exit 5; \
    fi

# Configure ngrok
RUN mkdir -p /home/$USER/.config/ngrok && \
    echo -e "version: \"2\"\nauthtoken: \"$NGROK_TOKEN\"\nregion: us\ntunnels:\n  ssh:\n    proto: tcp\n    addr: 22" > /home/$USER/.config/ngrok/ngrok.yml && \
    chown -R $USER:$USER /home/$USER/.config

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22
CMD ["/start.sh"]
