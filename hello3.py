'''
MINIMUMS AND MAXIMUMS

Power:      0   450
Speed(kph): 0   41.1
Heart rate: 78 167 STALE
Cadence:    0   103


NOTES

13281 samples in ride???
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

hr = 167

for x in range(15):
    print("{}:  WATTS: {},  KPH: {},  HR: {},  CAD: {}".format(x,
    data["RIDE"]["SAMPLES"][x]["WATTS"], 
    data["RIDE"]["SAMPLES"][x]["KPH"],
    data["RIDE"]["SAMPLES"][x]["HR"],
    data["RIDE"]["SAMPLES"][x]["CAD"]))
    '''
    if data["RIDE"]["SAMPLES"][x]["HR"] < hr:
        hr = data["RIDE"]["SAMPLES"][x]["HR"]
        print(x)
        print(hr)
    '''
    time.sleep(0.5)


# ----- OSC ----- #

c = OSC.OSCClient()
c.connect(('localhost', 6449))   # 127.0.0.1 is localhost

oscmsg = OSC.OSCMessage()
oscmsg.setAddress("/startup")
oscmsg.append("start")
oscmsg.append(len(data["RIDE"]["SAMPLES"]))
c.send(oscmsg)

for x in range(len(data["RIDE"]["SAMPLES"])):
    oscmsg = OSC.OSCMessage()
    oscmsg.setAddress("/startup")

    oscmsg.append(data["RIDE"]["SAMPLES"][x]["WATTS"])
    oscmsg.append(data["RIDE"]["SAMPLES"][x]["KPH"])
    oscmsg.append(data["RIDE"]["SAMPLES"][x]["HR"])
    oscmsg.append(data["RIDE"]["SAMPLES"][x]["CAD"])
    c.send(oscmsg)
    
    time.sleep(0.009)

oscmsg = OSC.OSCMessage()
oscmsg.setAddress("/startup")
oscmsg.append("done")
c.send(oscmsg)
# ----- Done ----- #

print(len(data["RIDE"]["SAMPLES"]))
print("Done")