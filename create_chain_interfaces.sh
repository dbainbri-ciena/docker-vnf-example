#!/bin/bash

# If the bridge exists then wipe it so we can start fresh
sudo ovs-vsctl br-exists chain
if [ $? -eq 0 ]; then
    sudo ovs-vsctl del-br chain
fi

# Create chain bridge
sudo ovs-vsctl add-br chain
sudo ifconfig chain up

# Add ports on the bridge for the subscribers, vNFs, and uplink
sudo ovs-docker add-port chain eth0 subscriber_a --ipaddress=10.1.0.2/24 --macaddress=ca:fe:00:00:00:01
sudo ovs-docker add-port chain eth0 subscriber_b --ipaddress=10.1.0.5/24 --macaddress=ca:fe:00:00:00:02
sudo ovs-docker add-port chain in0 egress_vnf_a
sudo ovs-docker add-port chain out0 egress_vnf_a
sudo ovs-docker add-port chain in0 egress_vnf_b_subscriber_a
sudo ovs-docker add-port chain out0 egress_vnf_b_subscriber_a
sudo ovs-docker add-port chain in0 egress_vnf_b_subscriber_b
sudo ovs-docker add-port chain out0 egress_vnf_b_subscriber_b
sudo ovs-docker add-port chain in0 egress_vnf_c
sudo ovs-docker add-port chain out0 egress_vnf_c
sudo ovs-docker add-port chain up0 uplink --ipaddress=10.1.0.1/24
sudo ovs-docker add-port chain eth0 udp_service_subscriber_a --ipaddress=10.1.0.3/24
sudo ovs-docker add-port chain eth0 udp_service_subscriber_b --ipaddress=10.1.0.3/24
sudo ovs-docker add-port chain eth0 tcp_service_instance_1 --ipaddress=10.1.0.4/24
sudo ovs-docker add-port chain eth0 tcp_service_instance_2 --ipaddress=10.1.0.6/24
sudo ovs-docker add-port chain in0 ingress_vnf_a
sudo ovs-docker add-port chain out0 ingress_vnf_a
sudo ovs-docker add-port chain in0 ingress_vnf_b_instance_1
sudo ovs-docker add-port chain out0 ingress_vnf_b_instance_1
sudo ovs-docker add-port chain in0 ingress_vnf_b_instance_2
sudo ovs-docker add-port chain out0 ingress_vnf_b_instance_2
sudo ovs-docker add-port chain in0 ingress_vnf_b_instance_3
sudo ovs-docker add-port chain out0 ingress_vnf_b_instance_3

# Turn off check sum offloading. This was causing bad checksum calculations
for i in $(ifconfig | grep -v "^[~ ]" | grep Link | awk '{print $1}'); do
    if [ $i != "lo" ]; then
        sudo ethtool -K $i tx-checksum-ip-generic off > /dev/null
    fi
done

