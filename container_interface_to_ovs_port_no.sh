#!/bin/bash

ID=$(sudo ovs-vsctl --data=bare --no-heading --columns=name find interface external_ids:container_id="$1" external_ids:container_iface="$2")

sudo ovs-ofctl show chain | grep $ID | sed 's/(.*$//' | awk '{print $1}'
