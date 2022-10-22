#!/bin/bash

declare -a rmdirs=("/opt/consul" "/opt/nomad" "/etc/consul.d" "/etc/nomad.d")
declare -a rmfiles=("/etc/systemd/system/consul.service" "/etc/systemd/system/nomad.service")

sudo apt remove -y consul nomad

sudo systemctl stop consul.service
sudo systemctl disable consul.service
sudo systemctl stop nomad.service
sudo systemctl disable nomad.service

sudo systemctl daemon-reload

sudo chown -R $USER:$USER /opt/nomad

for ALLOC in `ls -d /opt/nomad/alloc/*`;
do
    for JOB in `ls ${ALLOC}| grep -v alloc`;
    do 
        sudo umount ${ALLOC}/${JOB}/secrets;
        sudo umount ${ALLOC}/${JOB}/dev;
        sudo umount ${ALLOC}/${JOB}/proc;
        sudo umount ${ALLOC}/${JOB}/alloc;
    done;
done

for file in "${rmfiles[@]}";
do
    if [ -f $file ]; then
        echo "Removing file: $file"
        sudo rm $file
    fi
done

for dir in "${rmdirs[@]}";
do
    if [ -d "$dir" ]; then
        echo "Removing dir: $dir"
        sudo rm -r $dir
    fi
done
