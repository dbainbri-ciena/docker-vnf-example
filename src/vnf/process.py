#!/usr/bin/python

import sys, socket, os, time, datetime
from scapy.all import *

def tobool(x):
    return x.lower() in ['true', 't', 'yes', 'y']

IN = os.environ.get('IN', 'in0')
OUT = os.environ.get('OUT', 'out0')
MASK = os.environ.get('MASK', '00:00:00:00:00:00')
DROP = os.environ.get('DROP', '')
DEBUG = tobool(os.environ.get('DEBUG', 'false'))

print "IN:    %s" % IN
print "OUT:   %s" % OUT
print "MASK:  %s" % MASK
print "DROP:  %s" % DROP
print "DEBUG: %s" % DEBUG

def process(pkt):
    global OUT, DEBUG
    src = pkt.src.split(':')
    mask = MASK.split(':')
    build = []
    for i in range(0, 6):
        if src[i] == "00":
            build.append(mask[i])
        else:
            build.append(src[i])
    pkt.src = ':'.join(build)

    if pkt.dst == DROP:
      if DEBUG:
          print "%s: %s [DROP]" % (datetime.datetime.utcnow(), pkt.src)
          sys.stdout.flush() 
    else:
      if DEBUG:
          print "%s: %s" % (datetime.datetime.utcnow(), pkt.src)
          sys.stdout.flush()
      sendp(pkt, iface=OUT, verbose=0)

while True:
    ifaces = os.listdir('/sys/class/net')
    if OUT in ifaces and IN in ifaces:
        break
    print "Waiting for interfaces %s and %s" % (IN, OUT)
    sys.stdout.flush()
    time.sleep(1)

print "Starting vNF processing"
sys.stdout.flush()


pkt = sniff(iface=IN, count=0, store=0, lfilter=lambda x: process(x))
