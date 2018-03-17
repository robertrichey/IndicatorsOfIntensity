8 => int numVoices;
int buffVoices[numVoices];

SndBuf2 buff[numVoices];
Envelope env[numVoices];
Pan2 pan[numVoices]; 

string filename[21];

for (0 => int i; i < filename.size(); i++) {
    <<< i >>>;
    "/bike2/STE-0" + Std.itoa(i) + ".wav" => filename[i];
}

for (0 => int i; i < buff.size(); i++) {
    buff[i] => env[i] => pan[i] => dac; // => pan[i]
}


960 / 3 => int x;

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
    if (Math.randomf() > threshold) {
        // play something
        spork ~ play();
    }
    if (i < peakDensity) {
        thresholdDecrement -=> threshold;
    }
    else {
        thresholdIncrement +=> threshold;
    }
    3::second => now;
}
5::second => now;

fun void play() {
    getVoice(buffVoices) => int which;
        
    if (which > -1) {
        me.dir() + filename[Math.random2(0, filename.size()-1)] => buff[which].read;
        
        // Choose gain settings
        if (Math.randomf() > 0.9) {
            3.0 => buff[which].gain;
        }
        else {
            Math.random2f(0.3, 2.5) => buff[which].gain;
        }
        
        buff[which].length() * 0.15 => env[which].duration;
        Math.random2f(-0.8, 0.8) => pan[which].pan;
        
        env[which].keyOn();
        buff[which].length() - env[which].duration() => now;
        
        env[which].keyOff();
        env[which].duration() => now;
        
        0 => buffVoices[which]; 
    }
}

fun int getVoice(int voices[]) {
    for (int i; i < voices.size(); i++) { 
        if (voices[i] == 0) {            
            1 => voices[i];
            return i;
        }
    }
    return -1;
}