#!/bin/bash

cni_plugin_ver="1.1.1"
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v$cni_plugin_ver/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v$cni_plugin_ver.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

echo ""
echo "Removing cni-plugins.tar.gz"
echo ""

rm cni-plugins.tar.gz
