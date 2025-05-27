FROM ubuntu:latest

# Install packages
RUN apt update && apt install -y wget curl sudo openssh-server ttyd

# Konfigurasi SSH
RUN mkdir /var/run/sshd && \
    echo 'root:76mantap' | chpasswd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Buat script startup
RUN echo '#!/bin/bash\n\
service ssh start\n\
ttyd -p 7681 ssh root@localhost\n' > /start.sh && chmod +x /start.sh

EXPOSE 22 7681

CMD ["/start.sh"]
