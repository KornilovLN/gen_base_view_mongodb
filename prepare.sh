#!/bin/bash

#cd /mnt/poligon
#mkdir gen_base_view_mongodb
#cd gen_base_view_mongodb

#echo "Create folder datagenerator"
#mkdir datagenerator

#echo "Create folder datauser"
#mkdir datauser

#echo "Create Docker-nets"
#docker network create net_gen_db
#docker network create net_db_user

# Проверка и создание папки для Data Generator
if [ ! -d "datagenerator" ]; then
  echo "Create folder datagenerator"
  mkdir datagenerator
else
  echo "Folder datagenerator already exists"
fi


# Проверка и создание папки для Data User
if [ ! -d "datauser" ]; then
  echo "Create folder datauser"
  mkdir datauser
else
  echo "Folder datauser already exists"
fi


# Проверка и создание Docker сетей
NET_GEN_DB_EXISTS=$(docker network ls --filter name=net_gen_db --format "{{ .Name }}")
if [ "$NET_GEN_DB_EXISTS" != "net_gen_db" ]; then
  echo "Create Docker network net_gen_db"
  docker network create net_gen_db
else
  echo "Docker network net_gen_db already exists"
fi


NET_DB_USER_EXISTS=$(docker network ls --filter name=net_db_user --format "{{ .Name }}")
if [ "$NET_DB_USER_EXISTS" != "net_db_user" ]; then
  echo "Create Docker network net_db_user"
  docker network create net_db_user
else
  echo "Docker network net_db_user already exists"
fi


echo "Create MongoDB container"
# Без сохранения базы (с ликвидацией контейнера)
#docker run --name my_mongo --network net_gen_db --network-alias mongo_gen --network net_db_user --network-alias mongo_user -d mongo:latest

# Добавили том для хранения базы данных
docker run --name my_mongo \
           --network net_gen_db \
           --network-alias mongo_gen \
           --network net_db_user \
           --network-alias mongo_user \
           -v mongo_data:/data/db \
           -d mongo:latest

