#!/bin/bash

# Create Virtual Switch and Data Plane interfaces
sudo ovs-vsctl add-br vnfchain
sudo ifconfig vnfchain up
sudo ovs-docker add-port vnfchain in0 vagrant_vnfa_1
sudo ovs-docker add-port vnfchain out0 vagrant_vnfa_1
sudo ovs-docker add-port vnfchain in0 vagrant_vnfb_1
sudo ovs-docker add-port vnfchain out0 vagrant_vnfb_1
sudo ovs-docker add-port vnfchain in0 vagrant_vnfc_1
sudo ovs-docker add-port vnfchain out0 vagrant_vnfc_1

# Create chain flows
sudo ovs-ofctl del-flows vnfchain
sudo ovs-ofctl add-flow vnfchain in_port=LOCAL,actions=output:1 # from input to vnfA
sudo ovs-ofctl add-flow vnfchain in_port=2,actions=output:3     # from vnfA to vnfB
sudo ovs-ofctl add-flow vnfchain in_port=4,actions=output:5     # from vnfB to vnfC
sudo ovs-ofctl add-flow vnfchain in_port=6,actions=output:LOCAL # from vnfC to output
