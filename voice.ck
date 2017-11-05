SndBuf buff[12];
Gain g;
Gain g2;
Gain g3;
DelayL d;
Envelope env;
Pan2 pan;
800::ms => env.duration;

for (0 => int i; i < buff.size(); i++) {
    "/recordings/Record_" + Std.itoa(i+5) + ".wav" => string filename;
    me.dir() + filename => buff[i].read;
    buff[i].samples() => buff[i].pos;
    
    // our patch - feedforward part
    buff[i] => g;
    buff[i] => g2;
}
g => d => env => pan => dac;
g2 => env => pan => dac;
// feedback
d => g3 => d;
//d => pan;
//g3 => pan;
-1.0 => pan.pan;
// set gain parameters
2.5 => g.gain;
2.5 => g2.gain;
0.95 => g3.gain;

RideData data;
data.getGrains(20) @=> SampleGrains oscGrains;

900000 => float totalDuration;
totalDuration / oscGrains.numberOfGrains => float shiftDur;

spork ~ play();

[-1.0, -0.5, 0.0, 0.5, 1.0] @=> float pans[];
// increase chance over time
while (true) {
    Math.random2(0, buff.size()-1) => int which;
    pans[Math.random2(0, pans.size()-1)] => pan.pan;
        
    0 => buff[which].pos;
    env.keyOn();
    buff[which].length() => now;
    env.keyOff();
    0.5::second => now;
}


fun void play() {
    // Play sound based on grain for total duration
    for (0 => int i; i < oscGrains.numberOfGrains - 1; i++) {
        
        Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 1, 40, oscGrains.power[i])) => 
        float startDelay;
        
        Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 1, 40, oscGrains.power[i + 1])) => 
        float endDelay;
        
        
        Std.mtof(getTransformation(oscGrains.minSpeed, oscGrains.maxSpeed, 0.5, 2.5, oscGrains.speed[i])) => 
        float startG;
        
        Std.mtof(getTransformation(oscGrains.minSpeed, oscGrains.maxSpeed, 0.5, 2.5, oscGrains.speed[i + 1])) => 
        float endG;
        
        
        Std.mtof(getTransformation(oscGrains.minCadence, oscGrains.maxCadence, 0.5, 2.5, oscGrains.cadence[i])) => 
        float startG2;
        
        Std.mtof(getTransformation(oscGrains.minCadence, oscGrains.maxCadence, 0.5, 2.5, oscGrains.cadence[i + 1])) => 
        float endG2;
        
        spork ~ shiftDelay(startDelay, endDelay, shiftDur);
        //spork ~ shiftG(startG, endG, shiftDur);
        //spork ~ shiftG2(startG2, endG2, shiftDur);

        shiftDur::ms => now;
    }
}
<<< "Done" >>>;

/*
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
*/

/** 
* Linear transformation:
* For a given value between [a, b], return corresponding value between [c, d]
* source: https://stackoverflow.com/questions/345187/math-mapping-numbers
*/
fun float getTransformation(float a, float b, float c, float d, float x) {
    return (x - a) / (b - a) * (d - c) + c;
}

fun void shiftDelay(float start, float finish, float duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current;
    current::ms => d.delay;
    
    for (0 => int i; i < duration; i++) {
        grain +=> current;
        current::ms => d.delay;
        1::ms => now;
    }
    finish::ms => d.delay;
}

fun void shiftG(float start, float finish, float duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current => g.gain;
    
    for (0 => int i; i < duration; i++) {
        grain +=> current => g.gain;
        1::ms => now;
    }
    finish => g.gain;
}

fun void shiftG2(float start, float finish, float duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current => g2.gain;
    
    for (0 => int i; i < duration; i++) {
        grain +=> current => g2.gain;
        1::ms => now;
    }
    finish => g2.gain;
}