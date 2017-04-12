#!/bin/bash

sudo ovs-vsctl br-exists chain
if [ $? -eq 0 ]; then
    sudo ovs-vsctl del-br chain
fi
