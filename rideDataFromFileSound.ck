//---------- PATCH ----------//

// create patch, keep quiet until OSC message is receved
SqrOsc sin1 => Envelope env1 => NRev rev1 => dac;
SqrOsc sin2 => Envelope env2 => NRev rev2 => dac;

0 => rev1.mix;
0 => rev2.mix;
0.6 => sin1.gain;
0.6 => sin2.gain;


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


// Read heart rate data into array
file.open("textfiles/heartRate.txt", FileIO.READ);

for (0 => int i; i < numberOfSamples; i++) {
    file => samples[i].heartRate.current;
}
file.close();


// Read cadence data into array
file.open("textfiles/cadence.txt", FileIO.READ);

for (0 => int i; i < numberOfSamples; i++) {
    file => samples[i].cadence.current;
}
file.close();


//---------- Calculate minimums, maximums, and averages ----------//

samples[0].power.current => float totalPower;
samples[0].speed.current => float totalSpeed;
samples[0].heartRate.current => float totalHeartRate;
samples[0].cadence.current => float totalCadence;
0 => int sampleCount;

samples[0].power.current => int minPower;
samples[0].power.current => int maxPower;

samples[0].speed.current => float minSpeed;
samples[0].speed.current => float maxSpeed;

samples[0].heartRate.current => int minHeartRate;
samples[0].heartRate.current => int maxHeartRate;

samples[0].cadence.current => int minCadence;
samples[0].cadence.current => int maxCadence;

// TODO unnecessary assignments with min function?
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
    
    // Heart rate
    Std.ftoi(Math.min(minHeartRate, samples[i].heartRate.current)) => minHeartRate;
    
    Std.ftoi(Math.max(maxHeartRate, samples[i].heartRate.current)) => maxHeartRate;
    maxHeartRate => samples[i].heartRate.max;
    
    samples[i].heartRate.current +=> totalHeartRate;
    getAverage(totalHeartRate, sampleCount) => 
    samples[i].heartRate.average;
    
    
    // Cadence
    Std.ftoi(Math.min(minCadence, samples[i].cadence.current)) => minCadence;
    
    Std.ftoi(Math.max(maxCadence, samples[i].cadence.current)) => maxCadence;
    maxCadence => samples[i].cadence.max;
    
    samples[i].cadence.current +=> totalCadence;
    Std.ftoi(getAverage(totalCadence, sampleCount)) => 
    samples[i].cadence.average;
}

<<< "Done" >>>;



///////////////////////////////



float powerAverages[130]; // numberOfSamples = 13281, round to 13000 / 100
0.0 => float power;

float speedAverages[130]; // numberOfSamples = 13281, round to 13000 / 100
0.0 => float speed;

// Fill array with average of every 100 samples
0 => int index;

for (0 => int i; i < 13000; i++) {
    samples[i].power.current +=> power;
    samples[i].speed.current +=> speed;

    
    if (i % 100 == 0 && i != 0) {
        power / 100 => powerAverages[index];
        0 => power;
        
        speed / 100 => speedAverages[index];
        0 => speed;
        
        index++;
    }
} 

// Assign final index
power / 100 => powerAverages[index];
speed / 100 => speedAverages[index];

for (0 => int i; i < index; i++) {
    <<< powerAverages[i], speedAverages[i] >>>;
}

powerAverages[0] => float minAveragePower;
powerAverages[0] => float maxAveragePower;

speedAverages[0] => float minAverageSpeed;
speedAverages[0] => float maxAverageSpeed;

for (1 => int i; i < speedAverages.size(); i++) {
    if (powerAverages[i] < minAveragePower) {
        powerAverages[i] => minAveragePower;
    }
    if (powerAverages[i] > maxAveragePower) {
        powerAverages[i] => maxAveragePower;
    }
    if (speedAverages[i] < minAverageSpeed) {
        speedAverages[i] => minAverageSpeed;
    }
    if (speedAverages[i] > maxAverageSpeed) {
        speedAverages[i] => maxAverageSpeed;
    }
}

<<<  minAveragePower, maxAveragePower, 
minAverageSpeed, maxAverageSpeed >>>;

// Play sound based on average power over each 100 samples

100::ms => env1.duration => env2.duration;

/*
[ 48, 50, 52, 53, 55, 57, 59,
60, 62, 64, 65, 67, 69, 71, 
72, 74, 76, 77, 79, 81, 83] @=> int p[];
*/

[ 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
72] @=> int p[];

for (0 => int i; i < speedAverages.size(); i++) {
    
    getTransformation(
    minAveragePower, maxAveragePower, 0, p.size()-1, powerAverages[i]) => float powerFreq;
    
    <<< powerFreq >>>;
    
    Std.mtof(p[Std.ftoi(Math.round(powerFreq))]) => powerFreq;
    powerFreq => sin1.freq;
    
    <<< powerFreq >>>;
    
    getTransformation(
    minAverageSpeed, maxAverageSpeed, 0, p.size()-1, speedAverages[i]) => float speedFreq;
    
    <<< speedFreq >>>;
    
    Std.mtof(p[Std.ftoi(Math.round(speedFreq))] - 12) => speedFreq;
    speedFreq => sin2.freq;
    
    <<< speedFreq >>>;
        
    <<< "", "" >>>;
    
    env1.keyOn();
    env2.keyOn();
    500::ms => now;
    env1.keyOff();
    env2.keyOn();
    env1.duration() => now;
}


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