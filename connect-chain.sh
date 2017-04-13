#!/bin/bash

LIST="subscriber_a,eth0 \
subscriber_b,eth0 \
egress_vnf_a,in0 \
egress_vnf_a,out0 \
egress_vnf_b_subscriber_a,in0 \
egress_vnf_b_subscriber_a,out0 \
egress_vnf_b_subscriber_b,in0 \
egress_vnf_b_subscriber_b,out0 \
egress_vnf_c,in0 \
egress_vnf_c,out0 \
ingress_vnf_a,in0 \
ingress_vnf_a,out0 \
ingress_vnf_b,in0 \
ingress_vnf_b,out0 \
udp_service_subscriber_a,eth0 \
udp_service_subscriber_b,eth0 \
tcp_service,eth0 \
uplink,up0"

TMPA=$(tempfile)
TMPB=$(tempfile)
cat $1 > $TMPA

# Substitue switch port numbers
for i in $LIST; do
    CONTAINER="$(echo $i | cut -d, -f1)"
    INTERFACE=$(echo $i | cut -d, -f2)
    cat $TMPA | sed -e "s/($i)/$(.\/container_interface_to_ovs_port_no.sh $CONTAINER $INTERFACE)/g" > $TMPB
    cp $TMPB $TMPA
done

# Substitue MAC addresses
for i in $LIST; do
    CONTAINER="$(echo $i | cut -d, -f1)"
    INTERFACE=$(echo $i | cut -d, -f2)
    MAC=$(docker exec -ti $CONTAINER ifconfig $INTERFACE | grep HWaddr | awk '{print tolower($5)}')
    cat $TMPA | sed -e "s/{$i}/$MAC/g" > $TMPB
    cp $TMPB $TMPA
done
cat $TMPA
rm -f $TMPA $TMPB
