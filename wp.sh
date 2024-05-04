#!/bin/bash
path=~/.ssh/id_rsa

sudo ssh-keygen -b 2048 -t rsa -f $path -q
