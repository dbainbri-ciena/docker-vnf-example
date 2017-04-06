#!/usr/bin/python

import sys, socket, os, time
from scapy.all import *

def tobool(x):
    return x.lower() in ['true', 't', 'yes', 'y']

IFACE = os.environ.get('IN', 'vnfchain')
DEBUG = tobool(os.environ.get('DEBUG', 'false'))

print "IFACE: %s" % IFACE
print "DEBUG: %s" % DEBUG

pkt = Ether(src="00:00:00:00:00:00", dst="00:00:00:00:00:00")/IP()/UDP()
sendp(pkt, iface=IFACE, verbose=0)

print "Sending packet on %s with ether src of  %s" % (IFACE, pkt.src)

print "Waiting for packet"
pkt = sniff(iface=IFACE, count=1)

print "Received packet on %s with ether src of %s" % (IFACE, pkt[0].src)

if pkt[0].src == "11:11:11:11:11:11":
    print "PASS"
else:
    print "FAIL"
    sys.exit(1)

pkt = Ether(src="00:00:00:00:00:00", dst="11:22:33:44:55:66")/IP()/UDP()
sendp(pkt, iface=IFACE, verbose=0)

print "Sending packet on %s with ether dst of  %s" % (IFACE, pkt.dst)

print "Waiting for packet"
pkt = sniff(iface=IFACE, timeout=5, count=1)

if not pkt or len(pkt) == 0:
    print "No packet recieved"
    print "PASS"
else:
    print "Packet received"
    print "FAIL"

