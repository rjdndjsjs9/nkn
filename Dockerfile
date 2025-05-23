FROM ubuntu:22.04

ARG NGROK_TOKEN="2xSKNcUIwXyC0ouLbI9c3NWAq8B_s5CjHFDREE26iSWgJCfv"
ARG VPS_PASSWORD="morningstar123"
ENV USER="morningstar"

RUN apt-get update && apt-get install -y \
    openssh-server \
    wget \
    curl \
    unzip \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
RUN echo "PermitRootLogin no" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

RUN useradd -m -s /bin/bash $USER && \
    echo "$USER:$VPS_PASSWORD" | chpasswd && \
    usermod -aG sudo $USER

RUN wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O ngrok.tgz && \
    tar xvzf ngrok.tgz -C /usr/local/bin && \
    rm ngrok.tgz && \
    chmod +x /usr/local/bin/ngrok

RUN mkdir -p /home/$USER/.ngrok2 && \
    echo "authtoken: $NGROK_TOKEN" > /home/$USER/.ngrok2/ngrok.yml && \
    chown -R $USER:$USER /home/$USER/.ngrok2

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22
CMD ["/start.sh"]
