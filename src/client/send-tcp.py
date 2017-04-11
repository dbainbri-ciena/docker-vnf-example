import socket, os

TCP_SEND_IP = os.environ.get('TCP_SEND_IP', '127.0.0.1')
TCP_SEND_PORT = int(os.environ.get('TCP_SEND_PORT', 5080))
MESSAGE = 'Hello'

print "TX         : %s:%s" % (TCP_SEND_IP, TCP_SEND_PORT)
print "MSG        : %s" % MESSAGE
print "-----"

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

sock.connect((TCP_SEND_IP, TCP_SEND_PORT))
print "CX  : %s:%s" % (TCP_SEND_IP, TCP_SEND_PORT)

print "+TX : %s:%s -> %s" % (TCP_SEND_IP, TCP_SEND_PORT, MESSAGE)
sock.send(MESSAGE)
data = sock.recv(1024)
print "+RX : %s:%s -> %s " % (TCP_SEND_IP, TCP_SEND_PORT, data)
sock.close()
print "+DX : %s:%s" % (TCP_SEND_IP, TCP_SEND_PORT)
