'''
DESCRIPTION

Writes to a txt file the total number of samples in a JSON file, followed by the
power recorded at each sample


NOTES

can use pprint - may be useful w/ formatting
'''

import json
from pprint import pprint


# ----- JSON ----- #

with open('ride_data.json') as data_file:
	data = json.load(data_file)


# ----- File IO ----- #

numSamples = len(data["RIDE"]["SAMPLES"])

# Write speed samples to a file
fo = open("numberOfSamples.txt", "w+")
fo.write(str(numSamples))
fo.close()

# Write power
fo = open("power.txt", "w+")
for sample in range(numSamples):
    fo.write(str(data["RIDE"]["SAMPLES"][sample]["WATTS"]) + "\n")
fo.close()

# Write speed 
fo = open("speed.txt", "w+")
for sample in range(numSamples):
    fo.write(str(data["RIDE"]["SAMPLES"][sample]["KPH"]) + "\n")
fo.close()

# Write heart rate 
fo = open("heartRate.txt", "w+")
for sample in range(numSamples):
    fo.write(str(data["RIDE"]["SAMPLES"][sample]["HR"]) + "\n")
fo.close()

# Write cadence
fo = open("cadence.txt", "w+")
for sample in range(numSamples):
    fo.write(str(data["RIDE"]["SAMPLES"][sample]["CAD"]) + "\n")
fo.close()


# ----- Done ----- #

print("Done")