import socket
import json
import datetime
host = socket.gethostbyname('localhost')
port = 8083

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.bind((host, port))
sock.listen(1)

print 'waiting for connection...'
(client_sock, client_addr) = sock.accept()
from datetime import datetime as dt

tdatetime = dt.now()
time = tdatetime.strftime('%Y/%m/%d')
dict = {
    "person": "Kohei",
    "time": time,
    "text": "Hello World"
}
jsonInit = json.dumps(dict)
client_sock.send(jsonInit)

print 'connection start'
while True:
    msg = client_sock.recv(1024)
    #msg = msg.rstrip()

    if msg == "":
      client_sock.send("server : connection end \n\n")
      print 'connection end'
      break
    else:
      data = json.loads(msg)
      person = data["person"]
      time = data["time"]
      recvtext = data["text"]
      dict2 = {
          "person": "Kohei",
          "time": time,
          "text": recvtext
      }
      jsondata = json.dumps(dict2)
      client_sock.send(jsondata)
      #client_sock.send("from server : %s" % msg)
      #client_sock.send(msg)
      print "%s" % time
      print "from %s : %s end" % (person, recvtext)
client_sock.close()
sock.close()
