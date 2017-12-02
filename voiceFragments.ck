5 => int numVoices;
int buffVoices[numVoices];

SndBuf2 buff[numVoices];
Envelope env[numVoices];
NRev rev[numVoices];
Pan2 pan[numVoices]; 

Delay del[numVoices];

string filename[23];

for (0 => int i; i < filename.size(); i++) {
    <<< i >>>;
    "/voice/" + Std.itoa(i) + ".wav" => filename[i];
}

for (0 => int i; i < buff.size(); i++) {
    buff[i] => env[i] => rev[i] => pan[i] => dac;
    buff[i] => del[i] => del[i] => rev[i];
    2000::ms => del[i].max;
}

now + 10::second => time later;

while (now < later) {
    spork ~ play();
    Math.random2(100, 1000)::ms => now;
}
4000::ms => now;

fun void play() {
    getVoice2(buffVoices) => int which;
    
    if (Math.randomf() > 0.7) {
        Math.random2f(0.1, 0.8) => rev[which].mix;
    }
    else {
        0 => rev[which].mix;
    }
    
    if (Math.randomf() > 1.7) {
        Math.random2f(0.1, 0.8) => del[which].gain;
        Math.random2f(50, 2000)::ms => del[which].delay;
    }
    else {
        0 => del[which].gain;
    }
    
    me.dir() + filename[Math.random2(0, filename.size()-1)] => buff[which].read;
    Math.random2f(0.5, 2.5) => buff[which].gain;
    10::ms => env[which].duration;
    Math.random2f(-0.8, 0.8) => pan[which].pan;
    Math.random2(0, buff[which].samples()-1) => buff[which].pos;
    <<< buff[which].samples() >>>;
    
    env[which].keyOn();
    Math.random2(100, 1000)::ms => now;
    
    env[which].keyOff();
    env[which].duration() => now;
    
    0 => buffVoices[which]; 
}

fun int getVoice2(int voices[]) {    
    while (true) { 
        Math.random2(0, voices.size()-1) => int which;
        
        if (voices[which] == 0) {            
            1 => voices[which];
            return which;
        }
    }
}

/*
960 / 4 => int x;

1.0 => float threshold;
0.0 => float minChance;
threshold - minChance => float difference;

<<< x / 1.618 >>>;
Std.ftoi(x / 1.618) => int peakDensity;

difference / peakDensity => float thresholdDecrement;
difference / (x - peakDensity) => float thresholdIncrement;

<<< difference / peakDensity >>>;
<<< difference / (x - peakDensity) >>>;


for (0 => int i; i < x; i++) {
    Math.randomf() => float chance;
    //1 => float chance;
    
    if (chance > threshold) {
        // play something
        spork ~ play();
    }
    if (i < peakDensity) {
        thresholdDecrement -=> threshold;
    }
    else {
        thresholdIncrement +=> threshold;
    }
    4::second => now;
}
5::second => now;
*/