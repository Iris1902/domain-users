#!/bin/bash
exec > >(tee /dev/tty) 2>&1
set -x
apt update -y
apt install -y docker.io curl
curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

cat <<EOL > /home/ubuntu/docker-compose.yml
version: '3'
services:
  ${name}:
    image: ${image}:${tag}
    ports:
      - "${port}:${port}"
    environment:
      - PORT=${port}
      - DB_KIND=${db_kind}
      - JDBC_URL=${jdbc_url}
      - DB_USERNAME=${db_username}
      - DB_PASSWORD=${db_password}
EOL

systemctl start docker
systemctl enable docker
cd /home/ubuntu
docker-compose up -d
