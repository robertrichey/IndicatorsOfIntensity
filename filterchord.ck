// take me to your leader (talk into the mic)
// gewang, prc

// our patch - feedforward part
SndBuf buff => Gain g => DelayL d => ResonZ filt => Pan2 pan;
g => DelayL d2 => ResonZ filt2 => pan;
g => DelayL d3 => ResonZ filt3 => pan;

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


me.dir() + filename => buff.read;

2 => float x;

0 => int index;

spork ~ panShift();

// time loop
while (true) {
    Math.random2f(-1.0, 1.0) => pan.pan;
    <<< pan.pan(), "s" >>>;
    me.dir() + filename[index++ % filename.size()] => buff.read;

    // set parameters
    x * 1::ms => d.delay;
    (second / d.delay()) => filt.freq;
    
    x * 1.3333 * 1::ms => d2.delay;
    (second / d2.delay()) => filt2.freq;
    
    x * 1.6667 * 1::ms => d3.delay;
    (second / d3.delay()) => filt3.freq;
    
    // AVOID Q OF 0.01 - LOUD
    0.05 => filt.Q => filt2.Q => filt3.Q;
    
    1.0 => g.gain;
    0.05 => g2.gain;
    0.95 => g3.gain => g4.gain => g5.gain;
    
    buff.length() => now;
    0 => buff.pos;
    Math.random2f(1, 12) => x;
    <<< x >>>;
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