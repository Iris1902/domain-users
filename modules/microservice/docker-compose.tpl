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
  user-create:
    image: ${image_user_create}
    ports:
      - "${port_user_create}:7000"
    environment:
      - PORT=7000
      - DB_KIND=${db_kind}
      - JDBC_URL=${jdbc_url}
      - DB_USERNAME=${db_username}
      - DB_PASSWORD=${db_password}
  user-read:
    image: ${image_user_read}
    ports:
      - "${port_user_read}:7001"
    environment:
      - PORT=7001
      - DB_KIND=${db_kind}
      - JDBC_URL=${jdbc_url}
      - DB_USERNAME=${db_username}
      - DB_PASSWORD=${db_password}
  user-update:
    image: ${image_user_update}
    ports:
      - "${port_user_update}:7002"
    environment:
      - PORT=7002
      - DB_KIND=${db_kind}
      - JDBC_URL=${jdbc_url}
      - DB_USERNAME=${db_username}
      - DB_PASSWORD=${db_password}
  user-delete:
    image: ${image_user_delete}
    ports:
      - "${port_user_delete}:7003"
    environment:
      - PORT=7003
      - DB_KIND=${db_kind}
      - JDBC_URL=${jdbc_url}
      - DB_USERNAME=${db_username}
      - DB_PASSWORD=${db_password}
EOL

systemctl start docker
systemctl enable docker
cd /home/ubuntu
docker-compose up -d
