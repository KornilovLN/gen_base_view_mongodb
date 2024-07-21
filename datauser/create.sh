#!/bin/bash

docker build -t data_user .
docker run --name data_user --network net_db_user data_user
