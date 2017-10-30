
RideData data;
data.getGrains(5) @=> SampleGrains oscGrains;

1 => int isOff;
// PATCH

SndBuf buff => ResonZ filter => dac;
buff  => ResonZ filter2 => dac;
buff  => ResonZ filter3 => dac;
buff  => ResonZ filter4 => dac;

me.dir() + "water.wav" => buff.read;
5 => buff.gain;

30 => int q;
q => filter4.Q;
q => filter3.Q;
q => filter2.Q;
q => filter.Q;

//0.1 => rev.mix;


227000 => float totalDuration;
totalDuration / oscGrains.numberOfGrains => float shiftDur;

// Play sound based on grain for total duration
for (0 => int i; i < oscGrains.numberOfGrains - 1; i++) {
    /*
    Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 36, 94, oscGrains.power[i])) => 
    float startCarFreq;
    
    Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 36, 94, oscGrains.power[i + 1])) => 
    float endCarFreq;
    */
    
    getTransformation(oscGrains.minSpeed, oscGrains.maxSpeed, 200, 6400, oscGrains.speed[i]) => 
    float startModFreq;
    
    getTransformation(oscGrains.minSpeed, oscGrains.maxSpeed, 200, 6400, oscGrains.speed[i + 1]) => 
    float endModFreq;
    
    /*
    getTransformation(oscGrains.minCadence, oscGrains.maxCadence, 0.03, 0.05, oscGrains.cadence[i]) => 
    float startCarGain;
    
    getTransformation(oscGrains.minCadence, oscGrains.maxCadence, 0.03, 0.05, oscGrains.cadence[i + 1]) => 
    float endCarGain;
    
    
    getTransformation(oscGrains.minHeartRate, oscGrains.maxHeartRate, 0, 10000, oscGrains.heartRate[i]) => 
    float startModGain;
    
    getTransformation(oscGrains.minHeartRate, oscGrains.maxHeartRate, 0, 10000, oscGrains.heartRate[i + 1]) => 
    float endModGain;
    */
    //spork ~ shiftCarPitch(startCarFreq, endCarFreq, shiftDur);
    //spork ~ shiftCarGain(startCarGain, endCarGain, shiftDur);
    spork ~ shiftModPitch(startModFreq, endModFreq, shiftDur);
    //spork ~ shiftModGain(startModGain, endModGain, shiftDur);
    shiftDur::ms => now;
    
}
<<< "Done" >>>;
/*
// TODO: document, use isOn bool function
fun void turnOn(int a, int b, float sampleRate) {
    //(((a - b) * sampleRate) * 0.2)::ms => now;
    
    //500::ms => now;
    0 => isOff;
    (((a - b) * sampleRate) * 0.005)::ms => env.duration;
    env.keyOn();
    env.duration() => now;
    
    (((a - b) * sampleRate) * 0.995)::ms => env.duration;
    env.keyOff();
    env.duration() => now;
    1 => isOff;
}
*/
/** 
* Linear transformation:
* For a given value between [a, b], return corresponding value between [c, d]
* source: https://stackoverflow.com/questions/345187/math-mapping-numbers
*/
fun float getTransformation(float a, float b, float c, float d, float x) {
    return (x - a) / (b - a) * (d - c) + c;
}
/*
fun void shiftCarPitch(float start, float finish, float duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current => carrier.freq;
    
    for (0 => int i; i < duration; i++) {
        grain +=> current;
        current => carrier.freq;
        1::ms => now;
    }
    finish => carrier.freq;
}

fun void shiftCarGain(float start, float finish, float duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current => carrier.gain;
    
    for (0 => int i; i < duration; i++) {
        grain +=> current;
        current => carrier.gain;
        1::ms => now;
    }
    finish => carrier.gain;
}
*/
fun void shiftModPitch(float start, float finish, float duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current;
    
    current => filter.freq;
    filter.freq() * (5/4) => filter2.freq;
    filter.freq() * 1.5 => filter3.freq;
    filter.freq() * 2 => filter4.freq;
    
    for (0 => int i; i < duration; i++) {
        grain +=> current;
        
        current => filter.freq;
        filter.freq() * (5/4) => filter2.freq;
        filter.freq() * 1.5 => filter3.freq;
        filter.freq() * 2 => filter4.freq;
        
        1::ms => now;
    }
    finish => filter.freq;
    filter.freq() * (5/4) => filter2.freq;
    filter.freq() * 1.5 => filter3.freq;
    filter.freq() * 2 => filter4.freq;
}
/*
fun void shiftModGain(float start, float finish, float duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current => modulator.gain;
    
    for (0 => int i; i < duration; i++) {
        grain +=> current;
        current => modulator.gain;
        1::ms => now;
    }
    finish => modulator.gain;
}
*/