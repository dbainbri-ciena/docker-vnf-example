#!/usr/local/bin/python 

import sys, socket, os, threading

RECEIVE_IP = os.environ.get('RECEIVE_IP', '0.0.0.0')
RECEIVE_PORT = int(os.environ.get('RECEIVE_PORT', 5080))
MESSAGE = os.environ.get('MESSAGE', 'Good morning')

print "RX ON: %s:%s" % (RECEIVE_IP, RECEIVE_PORT)
print "MSG  : %s" % MESSAGE
print "-----"
sys.stdout.flush()

def conversation(client_socket):
    data = client_socket.recv(1024)
    print "+RX : %s:%s -> %s" % (addr[0], addr[1], data)
    print "+TX : %s:%s -> %s" % (addr[0], addr[1], MESSAGE)
    sys.stdout.flush()
    client_socket.send(MESSAGE)
    client_socket.close()
    print "+DX : %s:%s" % (addr[0], addr[1])
    sys.stdout.flush()

receive_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
receive_sock.bind((RECEIVE_IP, RECEIVE_PORT))
receive_sock.listen(5)

while True:
    (client_socket, addr) = receive_sock.accept()
    print "CX  : %s:%s" % (addr[0], addr[1])
    sys.stdout.flush()
    threading.Thread(conversation(client_socket)).run()
