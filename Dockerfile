FROM ubuntu:22.04

# Set environment variables
ENV LANG en_US.utf8
ENV USER=morningstar
ENV PASSWORD=morningstar123
ARG NGROK_TOKEN

# Install dependencies in a single layer
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
        locales \
        openssh-server \
        wget \
        unzip \
        curl \
        jq && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
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

# Install ngrok (Northflank-friendly method)
RUN wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O ngrok.tgz && \
    tar xzf ngrok.tgz -C /usr/local/bin && \
    rm ngrok.tgz && \
    chmod +x /usr/local/bin/ngrok

# Configure ngrok
RUN mkdir -p /home/$USER/.config/ngrok && \
    echo -e "version: \"2\"\nauthtoken: \"$NGROK_TOKEN\"\nregion: us\ntunnels:\n  ssh:\n    proto: tcp\n    addr: 22" > /home/$USER/.config/ngrok/ngrok.yml && \
    chown -R $USER:$USER /home/$USER/.config

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Northflank-specific optimizations
EXPOSE 22
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s \
    CMD netstat -tuln | grep -q ':22 ' || exit 1

CMD ["/start.sh"]
