#!/bin/bash

docker build -t data_generator .
docker run --name data_generator --network net_gen_db data_generator
