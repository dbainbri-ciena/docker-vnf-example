#!/bin/bash

LIST="client,eth0 \
egress_vnf_a,in0 \
egress_vnf_a,out0 \
egress_vnf_b,in0 \
egress_vnf_b,out0 \
egress_vnf_c,in0 \
egress_vnf_c,out0 \
ingress_vnf_a,in0 \
ingress_vnf_a,out0 \
ingress_vnf_b,in0 \
ingress_vnf_b,out0 \
svc_udp,eth0 \
svc_tcp,eth0 \
uplink,up0"

TMPA=$(tempfile)
TMPB=$(tempfile)
cat $1 > $TMPA
for i in $LIST; do
    CONTAINER="vagrant_$(echo $i | cut -d, -f1)_1"
    INTERFACE=$(echo $i | cut -d, -f2)
    cat $TMPA | sed -e "s/($i)/$(.\/container_interface_to_ovs_port_no.sh $CONTAINER $INTERFACE)/g" > $TMPB
    cp $TMPB $TMPA
done
cat $TMPA
rm -f $TMPA $TMPB
