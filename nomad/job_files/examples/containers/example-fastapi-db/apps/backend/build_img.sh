#!/bin/bash

image_name="example-fastapi-pg"
registry_address="localhost:5000"

docker build . -t $image_name

docker tag $image_name:latest $registry_address/$image_name
docker push $registry_address/$image_name
