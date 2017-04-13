#!/usr/local/bin/python 

import sys, socket, os

RECEIVE_IP = os.environ.get('RECEIVE_IP', '0.0.0.0')
RECEIVE_PORT = int(os.environ.get('RECEIVE_PORT', 5068))
SEND_PORT = int(os.environ.get('SEND_PORT', 5067))
MESSAGE = os.environ.get('MESSAGE', 'Good morning')

print "RX ON: %s:%s" % (RECEIVE_IP, RECEIVE_PORT)
print "TX ON: :%s" % SEND_PORT
print "MSG  : %s" % MESSAGE
print "-----"
sys.stdout.flush()

receive_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
receive_sock.bind((RECEIVE_IP, RECEIVE_PORT))
send_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

while True:
    data, addr = receive_sock.recvfrom(1024) # buffer size is 1024 bytes
    print "RX  : %s:%s -> %s" % (addr[0], addr[1], data)
    print "+TX : %s:%s -> %s" % (addr[0], SEND_PORT, MESSAGE)
    sys.stdout.flush()
    send_sock.sendto(MESSAGE, (addr[0], SEND_PORT))
