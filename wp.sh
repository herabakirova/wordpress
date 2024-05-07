#!/bin/bash
path=~/.ssh/id_rsa

sleep 20
sudo ssh-keygen -b 2048 -t rsa -f $path -q
