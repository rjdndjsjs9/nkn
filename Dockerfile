FROM ubuntu:latest

ENV Password=76mantap

# Install SSH dan dependensi
RUN apt update && apt install -y openssh-server wget curl unzip && \
    echo "root:${Password}" | chpasswd && \
    mkdir -p /run/sshd

# Konfigurasi SSH
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Install cloudflared
RUN wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22

CMD ["/start.sh"]
