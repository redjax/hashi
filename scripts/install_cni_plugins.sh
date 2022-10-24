#!/bin/bash

cni_plugin_dir="/opt/cni/bin"
cni_plugin_ver="0.8.2"
cni_plugin_platform="linux"
cni_plugin_arch="amd64"
tar_file="cni-plugins.tar.gz"
cni_plugin_url="https://github.com/containernetworking/plugins/releases/download/v${cni_plugin_ver}/cni-plugins-${cni_plugin_platform}-${cni_plugin_arch}-v${cni_plugin_ver}.tgz"


function create_dir() {

  if [[ ! -d $1 ]]; then
    echo ""
    echo "Creating dir: $1"
    echo ""

    sudo mkdir -pv $1
  fi

}

function download_cni_plugins() {

  echo ""
  echo "Downloading CNI plugins v${cni_plugin_ver}"
  echo "Download URL:"
  echo "  ${cni_plugin_url}"
  echo ""

  curl -L -o "$tar_file" "${cni_plugin_url}"

}

function install_cni_plugins() {

  echo ""
  echo "Extracting $tar_file to $cni_plugin_dir"
  echo ""
  sudo tar -C $cni_plugin_dir -xzvf $tar_file

}

function cleanup() {

  if [[ -f $tar_file ]]; then
    sudo rm $tar_file
  fi

}

function main() {

  create_dir $cni_plugin_dir
  download_cni_plugins
  install_cni_plugins
  cleanup

}

main
