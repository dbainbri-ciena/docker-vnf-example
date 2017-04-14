#!/bin/bash

LIST=$(grep add-port create_chain_interfaces.sh | awk '{printf("%s,%s\n", $6, $5)}')

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
