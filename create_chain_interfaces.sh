#!/bin/bash

# If the bridge exists then wipe it so we can start fresh
sudo ovs-vsctl br-exists chain
if [ $? -eq 0 ]; then
    sudo ovs-vsctl del-br chain
fi

# Create chain bridge
sudo ovs-vsctl add-br chain
sudo ifconfig chain up

# Add ports on the bridge for the client, vNFs, and uplink
sudo ovs-docker add-port chain eth0 vagrant_client_1 --ipaddress=10.1.0.2/24
sudo ovs-docker add-port chain in0 vagrant_egress_vnf_a_1
sudo ovs-docker add-port chain out0 vagrant_egress_vnf_a_1
sudo ovs-docker add-port chain in0 vagrant_egress_vnf_b_1
sudo ovs-docker add-port chain out0 vagrant_egress_vnf_b_1
sudo ovs-docker add-port chain in0 vagrant_egress_vnf_c_1
sudo ovs-docker add-port chain out0 vagrant_egress_vnf_c_1
sudo ovs-docker add-port chain up0 vagrant_uplink_1 --ipaddress=10.1.0.1/24
sudo ovs-docker add-port chain eth0 vagrant_svc_udp_1 --ipaddress=10.1.0.3/24
sudo ovs-docker add-port chain eth0 vagrant_svc_tcp_1 --ipaddress=10.1.0.4/24
sudo ovs-docker add-port chain in0 vagrant_ingress_vnf_a_1
sudo ovs-docker add-port chain out0 vagrant_ingress_vnf_a_1
sudo ovs-docker add-port chain in0 vagrant_ingress_vnf_b_1
sudo ovs-docker add-port chain out0 vagrant_ingress_vnf_b_1

# Turn off check sum offloading. This was causing bad checksum calculations
for i in $(ifconfig | grep -v "^[~ ]" | grep Link | awk '{print $1}'); do
    sudo ethtool -K $i tx-checksum-ip-generic off
done

