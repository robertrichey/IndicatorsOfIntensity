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


//---------- PATCH ----------//


HevyMetl instrument1 => Pan2 pan1 => dac;
HevyMetl instrument2 => Pan2 pan2 => dac;
HevyMetl instrument3 => Pan2 pan3 => dac;
HevyMetl instrument4 => Pan2 pan4 => dac;

0.2 => instrument1.gain;
0.2 => instrument2.gain;
0.3 => instrument3.gain;
0.4 => instrument4.gain;

0.95 => pan1.pan;
0.65 => pan2.pan;
-0.65 => pan3.pan;
-0.95 => pan4.pan;

400::ms => dur q; // 500 ms = 8.75 min, 400 ms = 7 min
q * 2 => dur h;
q * 4 => dur w;
q / 2 => dur e;
q / 4 => dur s;

[
[w],
[h,h],
[h,q,q],
[q,q,q,q],

[q,e,e,q,e,e],
[e,e,q,e,q,e],
[e,s,s,q,e,e,e,s,s],
[e,e, s,s,s,s, e,e, s,s,s,s],

[s,s,e, e,s,s, s,s,e, e,s,s],
[e,q,e, s,e,s, s,s,s,s],
[s,e,s, s,s,s,e, s,s,s, e,e],
[s,s,s,s, s,s,s,s, s,s,s,s, s,s,s,s]
] @=> dur rhythms[][];

[37, 39, 41, 43, 45, 47] @=> int wt1[];

[36, 38, 40, 42, 44, 46] @=> int wt2[];

[36, 38, 39, 41, 42, 44, 45, 47] @=> int oct[];

[36, 38, 40, 41, 43, 45, 47] @=> int maj[];

// [36, 40, 43] @=> int maj[];


// use octaves 2,0,2,0
[51, 54, 57, 60] @=> int rite1[];
[36, 40, 43, 48] @=> int rite2[];

[36, 37, 38, 39, 40, 41, 
 42, 43, 44, 45, 46, 47] @=> int chrom[];


[
[36, 38, 43, 45],
[36, 38, 40, 42, 44, 46],
[36, 38, 39, 41, 42, 44, 45, 47],
[36, 38, 40, 41, 43, 45, 47],
[36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47] 
] @=> int chords[][];

[
[36],
[36, 43],
[36, 38, 43],
[36, 38, 43, 45],
[36, 38, 40, 43, 45],
[36, 38, 40, 43, 45, 47],
[36, 38, 40, 42, 43, 45, 47],
[36, 37, 38, 40, 42, 43, 45, 47],
[36, 37, 38, 40, 42, 43, 44, 45, 47],
[36, 37, 38, 39, 40, 42, 43, 44, 45, 47],
[36, 37, 38, 39, 40, 42, 43, 44, 45, 46, 47],
[36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47],
[36, 37, 38, 39, 40, 42, 43, 44, 45, 46, 47],
[36, 37, 38, 39, 40, 42, 43, 44, 45, 47],
[36, 37, 38, 40, 42, 43, 45, 47],
[36, 38, 40, 42, 43, 45, 47],
[36, 38, 40, 43, 45, 47],
[36, 38, 40, 43, 45],
[36, 38, 43, 45],
[36, 38, 43],
[36, 43],
[36]
] @=> int chords2[][];

 

spork ~ play(instrument1, minAveragePower, maxAveragePower, powerAverages, chords2, 3); // 3
spork ~ play(instrument4, minAverageSpeed, maxAverageSpeed, speedAverages, chords2, 0); // 0
spork ~ play(instrument2, minAverageCadence, maxAverageCadence, cadenceAverages, chords2, 2); // 2
spork ~ play(instrument3, minAverageHeartRate, maxAverageHeartRate, heartRateAverages, chords2, 1); // 1
8.75::minute => now;

fun void play(StkInstrument instrument, float oldBottom, float oldTop, float values[], int chords[][], int octave) {
    0.9 => float threshold;
   
    for (0 => int i; i < values.size(); i++) {
        Std.ftoi(getTransformation(
        oldBottom, oldTop, 0, rhythms.size()-1, values[i])) => int row;
        
        getChord(i, values, chords) => int which;
        <<< "i =", i, " chord =", which, "" >>>;
                        
        for (0 => int j; j < rhythms[row].size(); j++) { 
            Std.mtof(chords[which][Math.random2(0, chords[which].size()-1)] + 12 * octave) => instrument.freq;
            
            Math.random2f(0, 1) => float chance;

            if (chance > threshold) {
                1 => instrument.noteOn;
                rhythms[row][j]=> now;
                1 => instrument.noteOff;
            }
            else {
                rhythms[row][j]=> now;
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


fun int getChord(int i, float values[], int chords[][]) {
    values.size() => float numValues;
    numValues / chords.size() => float grain;
    return i / Std.ftoi(Math.ceil(grain));
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