SndBuf buff[12];
Envelope env;
Pan2 pan;

10::ms => env.duration;

for (0 => int i; i < buff.size(); i++) {
    "/recordings/Record_000" + Std.itoa(i+5) + ".wav" => string filename;
    me.dir() + filename => buff[i].read;
    buff[i].samples() => buff[i].pos;
    buff[i] => env => dac;//pan => dac;
}

while (true) {
    Math.random2f(-1.0, 1.0) => pan.pan;
    Math.random2(0, buff.size()-1) => int which;
    Math.random2f(0.05, 0.05) => buff[which].gain;
    0 => buff[which].pos;
    
    env.keyOn();
    buff[which].length() => now;
    env.keyOff();
    env.duration() => now;
    2000::ms => now;
}

RideData data;
data.getGrains(5) @=> SampleGrains oscGrains;

1 => int isOff;

// PATCH


900000 => float totalDuration;
totalDuration / oscGrains.numberOfGrains => float shiftDur;

fun void play() {
    // Play sound based on grain for total duration
    for (0 => int i; i < oscGrains.numberOfGrains - 1; i++) {
        
        Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 36, 94, oscGrains.power[i])) => 
        float startCarFreq;
        
        Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 36, 94, oscGrains.power[i + 1])) => 
        float endCarFreq;
        
        
        getTransformation(oscGrains.minSpeed, oscGrains.maxSpeed, 0, 500, oscGrains.speed[i]) => 
        float startModFreq;
        
        getTransformation(oscGrains.minSpeed, oscGrains.maxSpeed, 0, 500, oscGrains.speed[i + 1]) => 
        float endModFreq;
        
        
        getTransformation(oscGrains.minCadence, oscGrains.maxCadence, 0.08, 0.15, oscGrains.cadence[i]) => 
        float startCarGain;
        
        getTransformation(oscGrains.minCadence, oscGrains.maxCadence, 0.08, 0.15, oscGrains.cadence[i + 1]) => 
        float endCarGain;
        
        
        getTransformation(oscGrains.minHeartRate, oscGrains.maxHeartRate, 0, 10000, oscGrains.heartRate[i]) => 
        float startModGain;
        
        getTransformation(oscGrains.minHeartRate, oscGrains.maxHeartRate, 0, 10000, oscGrains.heartRate[i + 1]) => 
        float endModGain;
        
        spork ~ shiftCarPitch(startCarFreq, endCarFreq, shiftDur);
        spork ~ shiftCarGain(startCarGain, endCarGain, shiftDur);
        spork ~ shiftModPitch(startModFreq, endModFreq, shiftDur);
        spork ~ shiftModGain(startModGain, endModGain, shiftDur);
        shiftDur::ms => now;
    }
}
<<< "Done" >>>;

// TODO: document, use isOn bool function
fun void turnOn(int a, int b, float sampleRate) {
    (a - b) * sampleRate => float ringTime;
    
    0 => isOff;
    ringTime * 0.005::ms => env.duration;
    env.keyOn();
    env.duration() => now;
    
    ringTime * 0.995::ms => env.duration;
    env.keyOff();
    env.duration() => now;
    1 => isOff;
}

/** 
* Linear transformation:
* For a given value between [a, b], return corresponding value between [c, d]
* source: https://stackoverflow.com/questions/345187/math-mapping-numbers
*/
fun float getTransformation(float a, float b, float c, float d, float x) {
    return (x - a) / (b - a) * (d - c) + c;
}

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
