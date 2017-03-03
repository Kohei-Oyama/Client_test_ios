import socket
host = socket.gethostbyname('localhost')
port = 8080

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.bind((host, port))
sock.listen(1)

print 'waiting for connection...'
(client_sock, client_addr) = sock.accept()
client_sock.send("")
print 'connection start'
while True:
    msg = client_sock.recv(1024)
    msg = msg.rstrip()

    if msg == "":
      client_sock.send("server : connection end \n\n")
      print 'connection end'
      break
    else:
      #client_sock.send("server : %s \n" % msg)
      print "from client : %s end" % msg
client_sock.close()
sock.close()
