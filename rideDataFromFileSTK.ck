//---------- PATCH ----------//

// create patch, keep quiet until OSC message is receved
TriOsc sin1 => Envelope env1 => NRev rev1 => dac.left;
TriOsc sin2 => Envelope env2 => NRev rev2 => dac.right;


0 => rev1.mix;
0 => rev2.mix;
0.2 => sin1.gain;
0.2 => sin2.gain;



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

file.open("textfiles/heartRate.txt", FileIO.READ);

for (0 => int i; i < numberOfSamples; i++) {
    file => samples[i].heartRate.current;
    //<<<i, samples[i].heartRate.current>>>;
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

10 => int averageGrain;

numberOfSamples / averageGrain => int arraySize;

float powerAverages[arraySize];
0.0 => float power;

float speedAverages[arraySize];
0.0 => float speed;

// Fill array with average of every averageGrain samples
0 => int index;
0 => int count;

for (0 => int i; i < numberOfSamples; i++) {
    count++; 
    
    samples[i].power.current +=> power;
    samples[i].speed.current +=> speed;
    
    if (count % averageGrain == 0 && count != 0) {
        power / averageGrain => powerAverages[index];
        0 => power;
        
        speed / averageGrain => speedAverages[index];
        0 => speed;
        
        index++;
        0 => count;
    }
} 


// Find min/max averages
getMin(powerAverages) => float minAveragePower;
getMax(powerAverages) => float maxAveragePower;

getMin(speedAverages) => float minAverageSpeed;
getMax(speedAverages) => float maxAverageSpeed;

<<<  minAveragePower, maxAveragePower, minAverageSpeed, maxAverageSpeed >>>;


// Play sound based on average power over each 100 samples

5::ms => env1.duration => env2.duration;

/*
[ 48, 50, 52, 53, 55, 57, 59,
60, 62, 64, 65, 67, 69, 71, 
72, 74, 76, 77, 79, 81, 83] @=> int p[];
*/

[48, 50, 52, 55, 57,
60, 62, 64, 67, 69,
72, 74, 76, 79, 81] @=> int p[];

/*
[ 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 
60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 
72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83] @=> int p[];
*/
for (0 => int i; i < speedAverages.size(); i++) {
    
    /*
    getTransformation(
    minAveragePower, maxAveragePower, 0, p.size()-1, powerAverages[i]) => float powerFreq;
    
    Std.mtof(p[Std.ftoi(Math.round(powerFreq))] + 12) => powerFreq;
    powerFreq => sin1.freq;
    
    <<< powerFreq >>>;
    
    getTransformation(
    minAverageSpeed, maxAverageSpeed, 0, p.size()-1, speedAverages[i]) => float speedFreq;
    
    Std.mtof(p[Std.ftoi(Math.round(speedFreq))]) => speedFreq;
    speedFreq => sin2.freq;
    
    <<< speedFreq >>>;
        
    <<< "", "" >>>;
    */
    
    getTransformation(
    minAveragePower, maxAveragePower, 800, 1600, powerAverages[i]) => sin1.freq;
    
    <<< sin1.freq() >>>;
    
    getTransformation(
    minAverageSpeed, maxAverageSpeed, 400, 800, speedAverages[i]) => sin2.freq;
    
    <<< sin2.freq() >>>;
        
    <<< "", "" >>>;
    
    env1.keyOn();
    env2.keyOn();
    50::ms => now;
    env1.keyOff();
    env2.keyOn();
    env1.duration() => now;
}


/////////////////////////////////////////////////////////////////


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