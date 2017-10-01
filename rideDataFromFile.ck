//---------- PATCH ----------//

// create patch, keep quiet until OSC message is receved
/*
SinOsc modulator => SinOsc carrier => Envelope env => NRev rev => dac;

0.15 => rev.mix;
10::ms => env.duration;
0.5 => carrier.gain;
6 => modulator.freq;
10 => modulator.gain;

// Tell the oscillator to interpret input as frequency modulation
2 => carrier.sync; 
*/


//---------- File I/O ----------//

FileIO file;

// Get total number of samples and initialize array
file.open("textfiles/numberOfSamples.txt", FileIO.READ);

file => int numberOfSamples;
Sample samples[numberOfSamples];
file.close();


// Read power data into array
file.open("textfiles/power.txt", FileIO.READ);

for (0 => int i; i < numberOfSamples; i++) {
    file => samples[i].power.current;
}
file.close();


// Read speed data into array
file.open("textfiles/speed.txt", FileIO.READ);

for (0 => int i; i < numberOfSamples; i++) {
    file => samples[i].speed.current;
}
file.close();


// Read heart rate data into array - BROKEN
/*
file.open("textfiles/heartRate.txt", FileIO.READ);

for (0 => int i; i < numberOfSamples; i++) {
    file => samples[i].heartRate.current;
}
file.close();
*/

// Read cadence data into array
file.open("textfiles/cadence.txt", FileIO.READ);

for (0 => int i; i < numberOfSamples; i++) {
    file => samples[i].cadence.current;
}
file.close();


//---------- Calculate minimums, maximums, and averages ----------//

samples[0].power.current => float totalPower;
samples[0].speed.current => float totalSpeed;
samples[0].cadence.current => float totalCadence;
// 0.0 => float totalHeartRate;
1 => int sampleCount;

samples[0].power.current => int minPower;
samples[0].power.current => int maxPower;

samples[0].speed.current => float minSpeed;
samples[0].speed.current => float maxSpeed;

samples[0].cadence.current => int minCadence;
samples[0].cadence.current => int maxCadence;


for (1 => int i; i < numberOfSamples; i++) {    
    sampleCount++;
    
    // Power
    Std.ftoi(Math.min(minPower, samples[i].power.current)) => minPower;
    
    Std.ftoi(Math.max(maxPower, samples[i].power.current)) => maxPower;
    maxPower => samples[i].power.max;
    
    samples[i].power.current +=> totalPower;
    Std.ftoi(getAverage(totalPower, sampleCount)) => 
    samples[i].power.average;
    
    // Speed
    Math.min(minSpeed, samples[i].speed.current) => minSpeed;
    
    Math.max(maxSpeed, samples[i].speed.current) => maxSpeed;
    maxSpeed => samples[i].speed.max;
    
    samples[i].speed.current +=> totalSpeed;
    getAverage(totalSpeed, sampleCount) => 
    samples[i].speed.average;
    
    // Cadence
    Std.ftoi(Math.min(minCadence, samples[i].cadence.current)) => minCadence;
    
    Std.ftoi(Math.max(maxCadence, samples[i].cadence.current)) => maxCadence;
    maxCadence => samples[i].cadence.max;
    
    samples[i].cadence.current +=> totalCadence;
    Std.ftoi(getAverage(totalCadence, sampleCount)) => 
    samples[i].cadence.average;
}

<<< totalSpeed, sampleCount, samples[numberOfSamples-1].power.max, 
samples[numberOfSamples-1].speed.max, 
samples[numberOfSamples-1].cadence.max >>>;

<<< "Done" >>>;


fun float getAverage(float sum, int numItems) {
    return sum / numItems;
}

/** 
 * Linear transformation:
 * For a given value between [a, b], return corresponding value between [c, d]
 * source: https://stackoverflow.com/questions/345187/math-mapping-numbers
 */
fun float getTransformation(float a, float b, float c, float d, float x) {
    return (x - a) / (b - a) * (d - c) + c;
}