import OSC
import time
c = OSC.OSCClient()
c.connect(('localhost', 6449))   # localhost is 127.0.0.1

for x in range(5):
    oscmsg = OSC.OSCMessage()
    oscmsg.setAddress("/startup")
    oscmsg.append('HELLO')
    oscmsg.append(x)
    c.send(oscmsg)
    
    time.sleep(0.5)

# Done
print("Done")