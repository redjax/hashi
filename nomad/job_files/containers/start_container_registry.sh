#!/bin/bash

registry_port=5000

docker run -d \
    -p $registry_port:5000 \
    --restart=unless-stopped \
    --name nomad-registry \
    registry:2
