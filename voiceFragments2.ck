12 => int numVoices;
int buffVoices[numVoices];

SndBuf2 buff[numVoices];
Envelope env[numVoices];
NRev rev[numVoices];
Pan2 pan[numVoices]; 

Gain combGain[numVoices];
Gain dryGain[numVoices];
Gain delay1Gain[numVoices];
Gain delay2Gain[numVoices];
Gain delay3Gain[numVoices];

DelayL delay1[numVoices];
DelayL delay2[numVoices];
DelayL delay3[numVoices];


// Sound chain
for (0 => int i; i < numVoices; i++) {
    buff[i] => dryGain[i] => env[i] => rev[i] => pan[i] => dac;
    
    buff[i] => combGain[i];
    
    combGain[i] => delay1[i] => env[i];
    combGain[i] => delay2[i] => env[i];
    combGain[i] => delay3[i] => env[i];
    
    delay1[i] => delay1Gain[i] => delay1[i];
    delay2[i] => delay2Gain[i] => delay2[i];
    delay3[i] => delay3Gain[i] => delay3[i];
}


// Samples
string filename[23];

for (0 => int i; i < filename.size(); i++) {
    "/voice/" + Std.itoa(i) + ".wav" => filename[i];
}


while (true) {
    spork ~ play();
    Math.random2(500, 500)::ms => now;
}

fun void play() {
    getVoice2(buffVoices) => int which;
    
    if (Math.randomf() > 0.7) { 
        turnOnComb(which);
    }
    else {
        0 => combGain[which].gain;
        Math.random2f(0.1, 0.9) => dryGain[which].gain;

    }
    if (Math.randomf() > 0.7) { 
        Math.random2f(1.0, 0.8) => rev[which].mix;
    }
    else {
        0 => rev[which].mix;
    }
    
    me.dir() + filename[Math.random2(0, filename.size()-1)] => buff[which].read;
    10::ms => env[which].duration;
    Math.random2f(-0.8, 0.8) => pan[which].pan;
    Math.random2(0, buff[which].samples()-0) => buff[which].pos;
    <<< buff[which].samples() >>>;
    
    env[which].keyOn();
    Math.random2(500, 2000)::ms => now;
    
    env[which].keyOff();
    env[which].duration() => now;
    
    // Let reverb subside
    2000::ms => now;
    
    0 => buffVoices[which]; 
}

fun void turnOnComb(int which) {
    Math.random2f(0.4, 0.8) => dryGain[which].gain;
    Math.random2f(0.6, 0.8) => combGain[which].gain;
    Math.random2f(0.70, 0.99) => 
    delay1[which].gain => delay2[which].gain => delay3[which].gain;
    
    Math.random2f(1, 12) => float x;
    Math.random2(1, 12) => int y;
    Math.random2(1, 12) => int z;
    
    x::ms => delay1[which].delay;
    raiseByHalfSteps(x, y)::ms => delay2[which].delay;
    raiseByHalfSteps(x, z)::ms => delay3[which].delay;
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

/**
 * Raises a float x by y equally tempered half steps
 */
fun float raiseByHalfSteps(float x, float y) {
    return x * Math.pow(Math.pow(2, 1/12.0), y);
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