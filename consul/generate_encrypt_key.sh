#!/bin/bash

# randkey=$(openssl rand -base64 32)
randkey=$(consul keygen)

echo ""
echo "Hashicorp Consul encrypt key:"
echo "  $randkey"
echo ""
echo "Add this key to your consul.hcl before copying to /etc/consul"
echo ""

