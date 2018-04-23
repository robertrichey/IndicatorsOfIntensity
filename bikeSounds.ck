// Plays bicycle samples with increasing frequency until the golden
// section, then decrease frequency back to zero 

// TODO: convert into class and integrate with other files
8 => int numVoices;
int buffVoices[numVoices];

SndBuf2 buff[numVoices];
Envelope env[numVoices];
Pan2 pan[numVoices]; 

// Create array and populate with sounds
string filename[21];

for (0 => int i; i < filename.size(); i++) {
    <<< i >>>;
    "/bike_sounds/STE-0" + Std.itoa(i) + ".wav" => filename[i];
}

for (0 => int i; i < buff.size(); i++) {
    buff[i] => env[i] => pan[i] => dac;
}

// Calculate increments to chance to play sounds based on duration
// TODO: get totalDuration from outside file
960000 => int totalDuration;
totalDuration / 100 / 3 => int numChances;

1.0 => float threshold;
0.0 => float minChance;
threshold - minChance => float difference;

Std.ftoi(numChances / 1.618) => int peakDensity;

difference / peakDensity => float thresholdDecrement;
difference / (numChances - peakDensity) => float thresholdIncrement;

// Iterate based on totalDuration and frequency of play attempts (every 3 seconds) 
for (0 => int i; i < numChances; i++) {
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

/**
 * Plays a random sample with variable gain and panning
 */
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
        
        // Set envelope and panning
        buff[which].length() * 0.15 => env[which].duration;
        Math.random2f(-0.8, 0.8) => pan[which].pan;
        
        // Play
        env[which].keyOn();
        buff[which].length() - env[which].duration() => now;
        
        env[which].keyOff();
        env[which].duration() => now;
        
        0 => buffVoices[which]; 
    }
}

/**
 * Select next available voice from voices[]
 */ 
fun int getVoice(int voices[]) {
    for (int i; i < voices.size(); i++) { 
        if (voices[i] == 0) {            
            1 => voices[i];
            return i;
        }
    }
    return -1;
}