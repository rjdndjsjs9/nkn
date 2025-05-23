FROM ubuntu:22.04

# Set your Termius credentials
ENV USER=morningstar
ENV PASSWORD=morningstar123

# Install SSH and dependencies
RUN apt-get update && apt-get install -y \
    openssh-server \
    openssh-client \
    curl \
    && apt-get clean

# Configure SSH
RUN mkdir /run/sshd && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Create user with your Termius password
RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$PASSWORD" | chpasswd

# Copy the startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22
CMD ["/start.sh"]
