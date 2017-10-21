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



///////////////////////////////////////////////////



// Round down to nearest 1000
numberOfSamples % 1000 -=> numberOfSamples;

100 => int averageGrain;

numberOfSamples / averageGrain => int arraySize;

float powerAverages[arraySize];
0.0 => float power;

float speedAverages[arraySize];
0.0 => float speed;

float cadenceAverages[arraySize];
0.0 => float cadence;

float heartRateAverages[arraySize];
0.0 => float heartRate;

// Fill array with average of every averageGrain samples
0 => int index;
0 => int count;

for (0 => int i; i < numberOfSamples; i++) {
    count++; 
    
    samples[i].power.current +=> power;
    samples[i].speed.current +=> speed;
    samples[i].cadence.current +=> cadence;
    samples[i].heartRate.current +=> heartRate;
    
    if (count % averageGrain == 0 && count != 0) {
        power / averageGrain => powerAverages[index];
        0 => power;
        
        speed / averageGrain => speedAverages[index];
        0 => speed;
        
        cadence / averageGrain => cadenceAverages[index];
        0 => cadence;
        
        heartRate / averageGrain => heartRateAverages[index];
        0 => heartRate;
        
        index++;
        0 => count;
    }
} 


// Find min/max averages
getMin(powerAverages) => float minAveragePower;
getMax(powerAverages) => float maxAveragePower;

getMin(speedAverages) => float minAverageSpeed;
getMax(speedAverages) => float maxAverageSpeed;

getMin(cadenceAverages) => float minAverageCadence;
getMax(cadenceAverages) => float maxAverageCadence;

getMin(heartRateAverages) => float minAverageHeartRate;
getMax(heartRateAverages) => float maxAverageHeartRate;

<<< minAveragePower, maxAveragePower, minAverageSpeed, maxAverageSpeed >>>;
<<< minAverageCadence, maxAverageCadence, minAverageHeartRate, maxAverageHeartRate >>>;


//---------- PATCH ----------//

// create patch, keep quiet until OSC message is receved
SinOsc modulator => TriOsc carrier => NRev rev => dac;
// Envelope env =>

0.0 => rev.mix;
0.3 => carrier.gain;
0 => modulator.freq;
0 => modulator.gain;

// Tell the oscillator to interpret input as frequency modulation
2 => carrier.sync;

750 => int shiftDur;

// Play sound based on average power over each 100 samples
for (0 => int i; i < powerAverages.size() - 1; i++) {
    Std.mtof(getTransformation(minAverageSpeed, maxAverageSpeed, 48, 84, speedAverages[i])) => 
    float startCarFreq;
    
    Std.mtof(getTransformation(minAverageSpeed, maxAverageSpeed, 48, 84, speedAverages[i + 1])) => 
    float endCarFreq;
    
    
    getTransformation(minAverageCadence, maxAverageCadence, 0, 100, cadenceAverages[i]) => 
    float startModFreq;
    
    getTransformation(minAverageCadence, maxAverageCadence, 0, 100, cadenceAverages[i + 1]) => 
    float endModFreq;
    
    
    getTransformation(minAveragePower, maxAveragePower, 0.05, 0.6, powerAverages[i]) => 
    float startCarGain;
    
    getTransformation(minAveragePower, maxAveragePower, 0.05, 0.6, powerAverages[i + 1]) => 
    float endCarGain;
    
    
    getTransformation(minAverageHeartRate, maxAverageHeartRate, 1, 500, heartRateAverages[i]) => 
    float startModGain;
    
    getTransformation(minAverageHeartRate, maxAverageHeartRate, 1, 500, heartRateAverages[i + 1]) => 
    float endModGain;
    
    spork ~ shiftCarPitch(startCarFreq, endCarFreq, shiftDur);
    spork ~ shiftCarGain(startCarGain, endCarGain, shiftDur);
    spork ~ shiftModPitch(startModFreq, endModFreq, shiftDur);
    shiftModGain(startModGain, endModGain, shiftDur);
}

<<< "Done" >>>;

/** 
 * Linear transformation:
 * For a given value between [a, b], return corresponding value between [c, d]
 * source: https://stackoverflow.com/questions/345187/math-mapping-numbers
 */
fun float getTransformation(float a, float b, float c, float d, float x) {
    return (x - a) / (b - a) * (d - c) + c;
}

fun void shiftCarPitch(float start, float finish, int duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current => carrier.freq;
    
    for (0 => int i; i < duration; i++) {
        //<<< s.freq() >>>;
        grain +=> current;
        current => carrier.freq;
        1::ms => now;
    }
    finish => carrier.freq;
}

fun void shiftCarGain(float start, float finish, int duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current => carrier.gain;
    
    for (0 => int i; i < duration; i++) {
        //<<< s.freq() >>>;
        grain +=> current;
        current => carrier.gain;
        1::ms => now;
    }
    finish => carrier.gain;
}

fun void shiftModPitch(float start, float finish, int duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current => modulator.freq;
    
    for (0 => int i; i < duration; i++) {
        //<<< s.freq() >>>;
        grain +=> current;
        current => modulator.freq;
        1::ms => now;
    }
    finish => modulator.freq;
}

fun void shiftModGain(float start, float finish, int duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current => modulator.gain;
    
    for (0 => int i; i < duration; i++) {
        //<<< s.freq() >>>;
        grain +=> current;
        current => modulator.gain;
        1::ms => now;
    }
    finish => modulator.gain;
}



fun float getAverage(float sum, int numItems) {
    return sum / numItems;
}

fun float getMin(float arr[]) {
    arr[0] => float min;
    
    for (1 => int i; i < arr.size(); i++) {
        if (arr[i] < min) {
            arr[i] => min;
        }
    }
    return min;
}

fun float getMax(float arr[]) {
    arr[0] => float max;
    
    for (1 => int i; i < arr.size(); i++) {
        if (arr[i] > max) {
            arr[i] => max;
        }
    }
    return max;
}