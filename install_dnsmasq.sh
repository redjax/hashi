#!/bin/bash

dnsmasq_consul_conf="./dnsmasq/10-consul"

## dnsmasq will let consul proxy services by dns name, i.e. app1.service.consul

sudo apt install -y dnsmasq

echo ""
echo "Copying consul config to dnsmasq dir"
echo ""

sudo cp $dnsmasq_consul_conf /etc/dnsmasq.d/

echo ""
echo "Reloading daemon & restarting dnsmasq"
echo ""

sudo systemctl daemon-reload
sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq

echo ""
echo "dnsmasq configured. Check status with $ systemctl status dnsmasq"
echo ""
