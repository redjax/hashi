#!/bin/bash
curl -sLS https://get.hashi-up.dev | sh
sudo install hashi-up /usr/local/bin/

hashi-up version

rm hashi-up
