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
    "/recordings/Record_" + Std.itoa(i+5) + ".wav" => filename[i];
}


me.dir() + filename => buff.read;

12 => float x;

0 => int index;

// time loop
while (true) {
    Math.random2f(-1.0, 1.0) => pan.pan;
    <<< 1 >>>;
    me.dir() + filename[index++ % filename.size()] => buff.read;
        <<< 2 >>>;

    // set parameters
    x * 1::ms => d.delay;
    (second / d.delay()) => filt.freq;
    
    x * 1.25 * 1::ms => d2.delay;
    (second / d2.delay()) => filt2.freq;
    
    x * 1.5 * 1::ms => d3.delay;
    (second / d3.delay()) => filt3.freq;
    
    0.05 => filt.Q => filt2.Q => filt3.Q;
    
    1.0 => g.gain;
    0.05 => g2.gain;
    0.98 => g3.gain => g4.gain => g5.gain;
    
    buff.length() => now;
    0 => buff.pos;
    Math.random2f(10, 15) => x;
    <<< x >>>;
}