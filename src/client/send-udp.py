import socket, os

UDP_SEND_IP = os.environ.get('UDP_SEND_IP', '127.0.0.1')
UDP_SEND_PORT = int(os.environ.get('UDP_SEND_PORT', 5068))
UDP_RECEIVE_IP = os.environ.get('UDP_RECEIVE_IP', '0.0.0.0')
UDP_RECEIVE_PORT = int(os.environ.get('UDP_RECEIVE_PORT', 5067))
RETRY_COUNT = int(os.environ.get('RETRY_COUNT', 5))
MESSAGE = 'Hello'

print "RX         : %s:%s" % (UDP_RECEIVE_IP, UDP_RECEIVE_PORT)
print "TX         : %s:%s" % (UDP_SEND_IP, UDP_SEND_PORT)
print "MSG        : %s" % MESSAGE
print "RETRY_COUNT: %d" % RETRY_COUNT
print "-----"

send_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
if UDP_SEND_IP == '<broadcast>':
   send_sock.bind(('', 0))
   send_sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
receive_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
receive_sock.settimeout(3)
receive_sock.bind((UDP_RECEIVE_IP, UDP_RECEIVE_PORT))

while RETRY_COUNT > 0:
    print "TX  : %s:%s -> %s" % (UDP_SEND_IP, UDP_SEND_PORT, MESSAGE)
    send_sock.sendto(MESSAGE, (UDP_SEND_IP, UDP_SEND_PORT))

    try:
        data, addr = receive_sock.recvfrom(1024)
    except (socket.timeout):
        print "+TIMEOUT"
        RETRY_COUNT -= 1
        continue

    print "+RX : %s:%s -> %s " % (addr[0], addr[1], data)
    break
