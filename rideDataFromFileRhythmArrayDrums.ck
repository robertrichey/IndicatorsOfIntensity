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


//---------- MIDI -----------//


4 => int numberOfVoices;

// MIDI out setup 
MidiOut mout[numberOfVoices];

for (0 => int i; i < numberOfVoices; i++) {
    // try to open that port, fail gracefully
    if(!mout[i].open(i)) {
        <<< "Error: MIDI port did not open on port: ", i >>>;
        me.exit();
    }
}


//---------- PATCH ----------//


600::ms => dur q; // 500 ms = 8.75 min, 400 ms = 7 min
q * 2 => dur h;
q * 4 => dur w;
q / 2 => dur e;
q / 4 => dur s;

q / 3 => dur t;
q / 6 => dur s6;
t * 2 => dur qt;

q / 5 => dur q5;

[
[w],
[h,h],
[h,q,q],
[qt,q,q],

[q,e,e,q,e,e],
[e,e,q,e,q,e],
[e,s,s,q,e,e,e,s,s],
[e,e, t,t,t, e,e, s,s,s,s],

[qt, t,t, q,s,e,s, t,t,t,t],
[q, q5,q5,q5,q5,q5, e,e, q5,q5,q5,q5,q5],
[t,t,s6,s6, t,s6,s6,s6,s6, s6,s6,s6,s6,s6,s6],
[e,t,s,q5,s6, s,t,t, s,e,s,s6, q5,q5,q5,q5,s6,s6,s6,s6]
] @=> dur rhythms[][];

[37, 39, 41, 44, 46] @=> int chord1[];
[36, 38, 40, 43, 45] @=> int chord2[];
[41, 46, 47] @=> int chord3[];
[36, 40, 43] @=> int chord4[];

[51, 54, 57, 60] @=> int chord5[];
[36, 40, 43, 48] @=> int chord6[];

[36, 37, 38, 39, 40, 41, 
 42, 43, 44, 45, 46, 47] @=> int chord[];


spork ~ play(minAveragePower, maxAveragePower, powerAverages, 62, 3); // 3
spork ~ play(minAverageSpeed, maxAverageSpeed, speedAverages, 64, 0); // 0
spork ~ play(minAverageCadence, maxAverageCadence, cadenceAverages, 65, 2); // 2
spork ~ play(minAverageHeartRate, maxAverageHeartRate, heartRateAverages, 67, 1); // 1
8.75::minute => now;

fun void play(float oldBottom, float oldTop, float values[], int note, int voice) {
    0.9 => float threshold;
   
    for (0 => int i; i < values.size(); i++) {
        Std.ftoi(getTransformation(
            oldBottom, oldTop, 0, rhythms.size()-1, values[i])) => int row;        

        for (0 => int j; j < rhythms[row].size(); j++) {
            Math.random2f(0, 1) => float chance;

            if (chance > threshold) {
                MIDInote(voice, 1, note, 60);
                rhythms[row][j] => now;
                MIDInote(voice, 0, note, 60);
            }
            else {
                rhythms[row][j] => now;
            }
        }
        // assume grain of 50
        if (i < 160) {
            0.005 -=> threshold;
        }
        else {
            0.008 +=> threshold;
        }
    }
}

fun void MIDInote(int which, int onOff, int note, int velocity) {
    MidiMsg msg;
    
    if(onOff == 0) {
        128 => msg.data1;
    }
    else {
        144 => msg.data1;
    } 
    note => msg.data2;
    velocity => msg.data3; 
    mout[which].send(msg);
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