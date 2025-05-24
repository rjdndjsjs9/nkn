FROM ubuntu:22.04

# Hardcoded Termius credentials (no variables needed)
ENV USER=morningstar
ENV PASSWORD=morningstar123

# Install SSH and sudo, clean up after
RUN apt-get update -yq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    openssh-server \
    openssh-client \
    curl \
    sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure SSH securely
RUN mkdir -p /run/sshd && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config

# Create user with password and give sudo access
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$PASSWORD" | chpasswd && \
    usermod -aG sudo $USER && \
    chown -R $USER:$USER /home/$USER

# Copy autoconnect script and set permissions
COPY start.sh /start.sh
RUN chmod +x /start.sh && chown $USER:$USER /start.sh

USER morningstar

EXPOSE 22
CMD ["/start.sh"]
