// take me to your leader (talk into the mic)
// gewang, prc

// our patch - feedforward part
SndBuf buff => Gain g => DelayL d => Pan2 pan;
g => DelayL d2 => pan;
g => DelayL d3 => pan;

buff => Gain g2 => pan;
pan => dac;
// feedback
d => Gain g3 => d;
d2 => Gain g4 => d2;
d3 => Gain g5 => d3;

string filename[12];

for (0 => int i; i < filename.size(); i++) {
        <<< i >>>;
    "/recordings/Record_" + Std.itoa(i+5) + ".wav" => filename[i];
}

RideData data;
data.getGrains(20) @=> SampleGrains oscGrains;

900000 => float totalDuration;
totalDuration / oscGrains.numberOfGrains => float shiftDur;

spork ~ play();

2 => float x;

0 => int index;

spork ~ panShift();

// time loop
while (true) {
    Math.random2f(-1.0, 1.0) => pan.pan;
    <<< pan.pan(), "pan" >>>;
    me.dir() + filename[index++ % filename.size()] => buff.read;

    // set parameters
    x::ms => d.delay;
    
    raiseByHalfSteps(x, 2)::ms => d2.delay;
    
    raiseByHalfSteps(x, 7)::ms => d3.delay;
    
    // AVOID Q OF 0.01 - LOUD
    
    3.0 => g.gain;
    0.5 => g2.gain;
    0.98 => g3.gain => g4.gain => g5.gain;
    
    buff.length() => now;
    5000::ms => now;
    0 => buff.pos;
    //Math.random2f(1, 12) => x;
    //<<< x >>>;
}

fun void panShift() {
    while (true) {
        if (pan.pan() > 0) {
            panLeft();
        }
        else {
            panRight();
        }
    }
}

fun void panLeft() {
    while (pan.pan() > -0.95) {
        pan.pan() - 0.005 => pan.pan;
        15::ms => now;
        //<<< pan.pan() >>>;
    }
}

fun void panRight() {
    while (pan.pan() < 0.95) {
        pan.pan() + 0.005 => pan.pan;
        15::ms => now;
        //<<< pan.pan() >>>;
    }
}

fun void play() {
    // Play sound based on grain for total duration
    for (0 => int i; i < oscGrains.numberOfGrains - 1; i++) {       
        Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 3, 12, oscGrains.power[i])) => 
        float startDelay;
        
        Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 3, 12, oscGrains.power[i + 1])) => 
        float endDelay;
        
        spork ~ shiftDelay(startDelay, endDelay, shiftDur);
        
        shiftDur::ms => now;
    }
}

fun float getTransformation(float a, float b, float c, float d, float x) {
    return (x - a) / (b - a) * (d - c) + c;
}

fun void shiftDelay(float start, float finish, float duration) {
    finish - start => float diff;
    diff / duration => float grain;
    start => float current;
    current::ms => d.delay;
    
    // set parameters
    
    raiseByHalfSteps(current, 2)::ms => d2.delay;
    
    raiseByHalfSteps(current, 7)::ms => d3.delay;
    
    for (0 => int i; i < duration; i++) {
        grain +=> current;
 current::ms => d.delay;
    
    // set parameters
    
    raiseByHalfSteps(current, 2)::ms => d2.delay;
    
    raiseByHalfSteps(current, 7)::ms => d3.delay;
    1::ms => now;
    }
    finish::ms => d.delay;
    
    // set parameters
    
    raiseByHalfSteps(finish, 2)::ms => d2.delay;
    
    raiseByHalfSteps(finish, 7)::ms => d3.delay;
} 

/**
 * Raises a float x by y equally tempered half steps
 */
fun float raiseByHalfSteps(float x, float y) {
    return x * Math.pow(Math.pow(2, 1/12.0), y);
}