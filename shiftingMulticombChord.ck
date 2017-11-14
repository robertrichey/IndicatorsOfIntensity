SndBuf buffer;
Multicomb combs[3];
Pan2 pan;

buffer => combs[0] => dac;
buffer => combs[1] => dac;
buffer => combs[2] => dac;

1000 => int revTime; 
revTime::ms => combs[0].revtime;
revTime::ms => combs[1].revtime;
revTime::ms => combs[2].revtime;


string filepath[12];

for (0 => int i; i < filepath.size(); i++) {
    "/recordings/Record_" + Std.itoa(i+5) + ".wav" => filepath[i];
}

RideData data;
data.getGrains(25) @=> SampleGrains oscGrains;

900000 => float totalDuration;
totalDuration / oscGrains.numberOfGrains => float shiftDur;

//spork ~ play();

60 => int x;

0 => int index;

spork ~ panShift();

while (true) {
    Math.random2f(-1.0, 1.0) => pan.pan;
    <<< pan.pan(), "pan" >>>;
    me.dir() + filepath[index++ % filepath.size()] => buffer.read;
    
    /*
    // set parameters
    x::ms => d.delay;
    (second / d.delay()) => filt.freq;
    
    raiseByHalfSteps(x, 2)::ms => d2.delay;
    (second / d2.delay()) => filt2.freq;
    
    raiseByHalfSteps(x, 7)::ms => d3.delay;
    (second / d3.delay()) => filt3.freq;
    
    // AVOID Q OF 0.01 - LOUD
    0.1 => filt.Q => filt2.Q => filt3.Q;
    
    3.0 => g.gain;
    0.5 => g2.gain;
    0.95 => g3.gain => g4.gain => g5.gain;
    */
    
    //setDelays(Math.random2(60, 400));
    for (0 => int i; i < 1000; i++) {
        setDelays(x++);
        5::ms => now;
    }
    
    //buffer.length() => now;
    0 => buffer.pos;
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
        Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 50, 400, oscGrains.power[i])) => 
        float startDelay;
        
        Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 50, 400, oscGrains.power[i + 1])) => 
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
    setDelays(current);
    
    for (0 => int i; i < duration; i++) {
        grain +=> current;
        setDelays(current);
        1::ms => now;
    }
    setDelays(finish);
} 

fun void setDelays(float x) {
    // set parameters
    x => float freq1;
    combs[0].set(freq1, freq1);
    
    x * 1.5 => float freq2;
    combs[1].set(freq2, freq2);

    x * 12/11 => float freq3;
    combs[2].set(freq3, freq3);
}

/**
 * Raises a float x by y equally tempered half steps
 */
fun float raiseByHalfSteps(float x, float y) {
    return x * Math.pow(Math.pow(2, 1/12.0), y);
}