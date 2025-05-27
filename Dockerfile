FROM ubuntu:latest

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV Password=76mantap
ENV ngrokid=2xfeeDPiKN0W2NM3itCBX5ij873_4ZqTvbs78hFEHzex7BnGG

# Update dan install dependensi
RUN apt update -y && \
    apt upgrade -y && \
    apt install -y locales openssh-server wget unzip curl && \
    locale-gen en_US.UTF-8

# Setup SSH
RUN mkdir -p /run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo root:${Password} | chpasswd

# Download ngrok
RUN wget -q -O /ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip && \
    unzip -q /ngrok.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/ngrok

# Start script
RUN echo '#!/bin/bash' > /start.sh && \
    echo "ngrok config add-authtoken ${ngrokid}" >> /start.sh && \
    echo "/usr/sbin/sshd" >> /start.sh && \
    echo "ngrok tcp 22" >> /start.sh && \
    chmod +x /start.sh

EXPOSE 22

CMD ["/bin/bash", "/start.sh"]
