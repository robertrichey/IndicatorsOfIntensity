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

for (0 => int i; i < cadenceAverages.size(); i++) {
    speedAverages[i] +=> totalSpeedAverage;
    powerAverages[i] +=> totalPowerAverage;
} 

240000 => float totalDuration; // 60,000 ms == 1 min

totalSpeedAverage / totalDuration => float speedRatio;
totalPowerAverage / totalDuration => float powerRatio;


//////////////////////////


//---------- MIDI ----------//

4 => int numberOfVoices;

// MIDI out setup 
MidiOut mout[numberOfVoices];
int port[numberOfVoices];

for (0 => int i; i < numberOfVoices; i++) {
    // try to open that port, fail gracefully
    if(!mout[i].open(i)) {
        <<< "Error: MIDI port did not open on port: ", port >>>;
        me.exit();
    }
}

// Make a MIDI msg holder for sending


spork ~ play(2, minAveragePower, maxAveragePower, 60, 83, 
   powerAverages, speedAverages, speedRatio);
    
//spork ~ play(1, minAverageHeartRate, maxAverageHeartRate, 36, 48, 
  // heartRateAverages);
   
//   spork ~ play(0, minAverageHeartRate, maxAverageHeartRate, 41, 55, 
//   heartRateAverages);
    
play(3, minAverageSpeed, maxAverageSpeed, 84, 106, 
  speedAverages, powerAverages, powerRatio);

1::hour => now;

////////////////////////////////////////////////////


fun void play(int which, float oldBottom, float oldTop, 
    float newBottom, float newTop, float values[], float durationValues[], float ratio) {
        
    for (0 => int i; i < values.size(); i++) {
        getTransformation(oldBottom, oldTop, newBottom, 
            newTop, values[i]) => float freq; 
            
        Std.ftoi(getTransformation(minAverageHeartRate, maxAverageHeartRate, 30, 
            127, heartRateAverages[i])) => int gain;     
        <<< gain >>>;
        //gain => instrument.gain;
        Std.ftoi(Math.round(freq)) => int midiNum;
        
        MIDInote(which, 1, midiNum, gain);
        (durationValues[i] / ratio) => float ringTime;
        ringTime::ms => now;
        MIDInote(which, 0, midiNum, gain);
    }
}

fun void play(int which, float oldBottom, float oldTop, 
float newBottom, float newTop, float values[]) {
    
    for (0 => int i; i < values.size(); i++) {
        getTransformation(oldBottom, oldTop, newBottom, 
        newTop, values[i]) => float freq; 

Std.ftoi(Math.round(freq)) => int midiNum;
        
        MIDInote(which, 1, midiNum, 60);
        (totalDuration / values.size())::ms => now;
        MIDInote(which, 0, midiNum, 60);
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