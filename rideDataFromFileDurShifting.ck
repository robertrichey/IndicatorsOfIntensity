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

50 => int averageGrain;

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



/////// WORKSPACE ////////


0 => float totalSpeedAverage;
0 => float totalPowerAverage;
0 => float totalCadenceAverage;
0 => float totalHeartRateAverage;

for (0 => int i; i < cadenceAverages.size(); i++) {
    speedAverages[i] +=> totalSpeedAverage;
    powerAverages[i] +=> totalPowerAverage;
    cadenceAverages[i] +=> totalCadenceAverage;
    heartRateAverages[i] +=> totalHeartRateAverage;
} 

240000 => float totalDuration; // 60,000 ms == 1 min

totalSpeedAverage / totalDuration => float speedRatio;
totalPowerAverage / totalDuration => float powerRatio;
totalCadenceAverage / totalDuration => float cadenceRatio;
totalHeartRateAverage / totalDuration => float heartRateRatio;

//////////////////////////


//---------- PATCH ----------//


TriOsc instrument1 => NRev rev;//Envelope env1 => NRev rev;
TriOsc instrument2 => rev;//Envelope env2 => rev;
TriOsc instrument3 => rev => dac;//Envelope env3 => rev => dac;

0.0 => instrument3.gain;

0. => rev.mix;
0.2 => instrument1.gain;
0.2 => instrument2.gain;

//1::ms => env1.duration => env2.duration;

//500::ms => env3.duration;

//1 => env1.keyOn => env2.keyOn => env3.keyOn;


spork ~ play(instrument1, minAveragePower, maxAveragePower, 60, 72, powerAverages, 
    speedAverages, speedRatio, minAverageCadence, maxAverageCadence, cadenceAverages);
    
    //spork ~ play(instrument3, env3, minAverageHeartRate, maxAverageHeartRate, 48, 60, 
    //heartRateAverages, totalDuration / heartRateAverages.size());
    
spork ~ play(instrument2, minAverageSpeed, maxAverageSpeed, 72, 84, speedAverages, 
    powerAverages, powerRatio, minAverageHeartRate, maxAverageHeartRate, heartRateAverages);

//1 => env1.keyOff => env2.keyOff => env3.keyOff;

1::hour => now;
////////////////////////////////////////////////////


fun void play(TriOsc instrument, float oldBottom, float oldTop, float newBottom, 
    float newTop, float values[], float durationValues[], float ratio, float gainBottom, 
    float gainTop, float gainValues[]) {
        
    for (0 => int i; i < values.size() - 1; i++) {
        Std.mtof(getTransformation(oldBottom, oldTop, newBottom, 
            newTop, values[i])) => float startFreq; 
            
        Std.mtof(getTransformation(oldBottom, oldTop, newBottom, 
            newTop, values[i + 1])) => float endFreq;
            
        getTransformation(gainBottom, gainTop, 0.1, 0.6, 
            gainValues[i]) => float startGain;
        
        getTransformation(gainBottom, gainTop, 0.1, 0.6, 
            gainValues[i + 1]) => float endGain;
        
        Std.ftoi(Math.round(durationValues[i] / ratio)) => int duration;
        
        spork ~ shiftGain(instrument, startGain, endGain, duration);
        shiftPitch(instrument, startFreq, endFreq, duration);
        500::ms => now; 
    }
    <<< "Done" >>>;
}

fun void shiftPitch(TriOsc instrument, float start, float finish, int duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current => instrument.freq;
    
    for (0 => int i; i < duration; i++) {
        grain +=> current;
        current => instrument.freq;
        1::ms => now;
    }
    finish => instrument.freq;
}

fun void shiftGain(TriOsc instrument, float start, float finish, int duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current => instrument.gain;
    
    for (0 => int i; i < duration; i++) {
        grain +=> current;
        current => instrument.gain;
        1::ms => now;
    }
    finish => instrument.gain;
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


/** 
 * Linear transformation:
 * For a given value between [a, b], return corresponding value between [c, d]
 * source: https://stackoverflow.com/questions/345187/math-mapping-numbers
 */
fun float getTransformation(float a, float b, float c, float d, float x) {
    return (x - a) / (b - a) * (d - c) + c;
}