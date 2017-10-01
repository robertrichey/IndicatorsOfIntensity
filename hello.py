'''
MINIMUMS AND MAXIMUMS

Power:      0   392
Speed(kph): 0   83.6
Heart rate: 114 154
Cadence:    0   103


NOTES

21440 samples in ride

sleep 0.0055 to hear all samples in 2 minutes
''    0.014  '' ''   ''  ''      '' 5 ''

can use pprint - may be useful w/ formatting
'''


import OSC
import time
import json
from pprint import pprint


# ----- JSON ----- #

with open('test.json') as data_file:
	data = json.load(data_file)

maxKPH = 0

for x in range(15): 
    print("{}:  WATTS: {},  KPH: {},  HR: {},  CAD: {}".format(x,
    data["RIDE"]["SAMPLES"][x]["WATTS"], 
    data["RIDE"]["SAMPLES"][x]["KPH"],
    data["RIDE"]["SAMPLES"][x]["HR"],
    data["RIDE"]["SAMPLES"][x]["CAD"]))
    
    if data["RIDE"]["SAMPLES"][x]["KPH"] > maxKPH:
        maxKPH = data["RIDE"]["SAMPLES"][x]["KPH"]
        #print(x)
    time.sleep(0.5)
#print(maxKPH)


# ----- OSC ----- #

c = OSC.OSCClient()
c.connect(('localhost', 6449))   # 127.0.0.1 is localhost

for x in range(21440):
    oscmsg = OSC.OSCMessage()
    oscmsg.setAddress("/startup")
    #oscmsg.append('HELLO')
    oscmsg.append(data["RIDE"]["SAMPLES"][x]["WATTS"])
    oscmsg.append(data["RIDE"]["SAMPLES"][x]["KPH"])
    oscmsg.append(data["RIDE"]["SAMPLES"][x]["HR"])
    oscmsg.append(data["RIDE"]["SAMPLES"][x]["CAD"])
    c.send(oscmsg)
    
    time.sleep(0.014)


# ----- Done ----- #

print("Done")