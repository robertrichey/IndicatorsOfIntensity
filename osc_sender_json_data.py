'''
MINIMUMS AND MAXIMUMS

Power:      0   450
Speed(kph): 0   41.1
Heart rate: 78  167 STALE
Cadence:    0   103


NOTES

13281 samples in ride - Samples missing from 3306 to 3411
sleep 0.009  to hear all samples in 2 minutes
''    0.0226 '' ''   ''  ''      '' 5 ''

can use pprint - may be useful w/ formatting
'''


import OSC
import time
import json
from pprint import pprint


# ----- JSON ----- #

with open('test2.json') as data_file:
	data = json.load(data_file)


# ----- OSC ----- #

c = OSC.OSCClient()
c.connect(('localhost', 6449)) # 127.0.0.1

numSamples = len(data["RIDE"]["SAMPLES"])

# Send total number of samples (used to set array size)
oscmsg = OSC.OSCMessage()
oscmsg.setAddress("/startup")
oscmsg.append(numSamples)
c.send(oscmsg)

# Send each sample 
for sample in range(numSamples):
    oscmsg = OSC.OSCMessage()
    oscmsg.setAddress("/startup")

    oscmsg.append(data["RIDE"]["SAMPLES"][sample]["SECS"])
    oscmsg.append(data["RIDE"]["SAMPLES"][sample]["KM"])
    oscmsg.append(data["RIDE"]["SAMPLES"][sample]["WATTS"])
    oscmsg.append(data["RIDE"]["SAMPLES"][sample]["KPH"])
    oscmsg.append(data["RIDE"]["SAMPLES"][sample]["HR"])
    oscmsg.append(data["RIDE"]["SAMPLES"][sample]["CAD"])
    c.send(oscmsg)
    
    time.sleep(0.001)

oscmsg = OSC.OSCMessage()
oscmsg.setAddress("/startup")
oscmsg.append("done")
c.send(oscmsg)


# ----- Done ----- #

print("Done")