//---------- File I/O ----------//

FileIO file;

// Get total number of samples and initialize array
file.open("textfiles/numberOfSamples.txt", FileIO.READ);

file => int numberOfSamples;
Sample samples[numberOfSamples];
file.close();


// Read power data into array
file.open("textfiles/power.txt", FileIO.READ);

for (0 => int i; i < numberOfSamples; i++) {
    file => samples[i].power.current;
}
file.close();


// Read speed data into array
file.open("textfiles/speed.txt", FileIO.READ);

for (0 => int i; i < numberOfSamples; i++) {
    file => samples[i].speed.current;
}
file.close();


// Read heart rate data into array
file.open("textfiles/heartRate.txt", FileIO.READ);

for (0 => int i; i < numberOfSamples; i++) {
    file => samples[i].heartRate.current;
}
file.close();


// Read cadence data into array
file.open("textfiles/cadence.txt", FileIO.READ);

for (0 => int i; i < numberOfSamples; i++) {
    file => samples[i].cadence.current;
}
file.close();


//---------- Calculate minimums, maximums, and averages ----------//


samples[0].power.current => float totalPower;
samples[0].speed.current => float totalSpeed;
samples[0].heartRate.current => float totalHeartRate;
samples[0].cadence.current => float totalCadence;
0 => int sampleCount;

samples[0].power.current => int minPower;
samples[0].power.current => int maxPower;

samples[0].speed.current => float minSpeed;
samples[0].speed.current => float maxSpeed;

samples[0].heartRate.current => int minHeartRate;
samples[0].heartRate.current => int maxHeartRate;

samples[0].cadence.current => int minCadence;
samples[0].cadence.current => int maxCadence;


// TODO unnecessary assignments with min function?
for (1 => int i; i < numberOfSamples; i++) {    
    sampleCount++;
    
    // Power
    Std.ftoi(Math.min(minPower, samples[i].power.current)) => minPower;
    
    Std.ftoi(Math.max(maxPower, samples[i].power.current)) => maxPower;
    maxPower => samples[i].power.max;
    
    samples[i].power.current +=> totalPower;
    Std.ftoi(getAverage(totalPower, sampleCount)) => 
    samples[i].power.average;
    
    // Speed
    Math.min(minSpeed, samples[i].speed.current) => minSpeed;
    
    Math.max(maxSpeed, samples[i].speed.current) => maxSpeed;
    maxSpeed => samples[i].speed.max;
    
    samples[i].speed.current +=> totalSpeed;
    getAverage(totalSpeed, sampleCount) => 
    samples[i].speed.average;
    
    // Heart rate
    Std.ftoi(Math.min(minHeartRate, samples[i].heartRate.current)) => minHeartRate;
    
    Std.ftoi(Math.max(maxHeartRate, samples[i].heartRate.current)) => maxHeartRate;
    maxHeartRate => samples[i].heartRate.max;
    
    samples[i].heartRate.current +=> totalHeartRate;
    getAverage(totalHeartRate, sampleCount) => 
    samples[i].heartRate.average;
    
    
    // Cadence
    Std.ftoi(Math.min(minCadence, samples[i].cadence.current)) => minCadence;
    
    Std.ftoi(Math.max(maxCadence, samples[i].cadence.current)) => maxCadence;
    maxCadence => samples[i].cadence.max;
    
    samples[i].cadence.current +=> totalCadence;
    Std.ftoi(getAverage(totalCadence, sampleCount)) => 
    samples[i].cadence.average;
}

<<< "Done" >>>;


//---------- PATCH ----------//

1 => int numBuffVoices;
1 => int numBarVoices;
1 => int numFluteVoices;
3 => int numPianoVoices;
5 => int numSineVoices;
1 => int numMandolinVoices;

int buffVoices[numBuffVoices];
int pianoVoices[numPianoVoices];
int sineVoices[numSineVoices];
int mandolinVoices[numMandolinVoices];
int fluteVoices[numFluteVoices];
int barVoices[numBarVoices];


SndBuf buff[numBuffVoices]; // filter, multiple sounds, keep track of duration between drums
ModalBar bars[numBarVoices];
Flute flute[numFluteVoices];
Wurley piano[numPianoVoices];
SinOsc sine[numSineVoices];
Mandolin mandolin[numMandolinVoices]; // expand on playing algos
Mandolin mandolinChord[3]; // for playing a chord

Envelope env[numSineVoices]; // for sine waves
NRev rev;

makePatch(buff, numBuffVoices, rev);
makePatch(bars, numBarVoices, rev);
makePatch(piano, numPianoVoices, rev);
makePatch(flute, numFluteVoices, rev);
makePatch(sine, env, numSineVoices, rev);
makePatch(mandolin, numMandolinVoices, rev);
makePatch(mandolinChord, rev);


rev => dac;

// TODO: where to set?
me.dir() + "bass_drum.wav" => buff[0].read;
//buff[0].samples() => buff[0].pos;

// TODO: bad use of global, bool?
0 => int lastDrum;

900000 => float totalDuration;
totalDuration / numberOfSamples => float sampleRate;

0.1 => rev.mix;

// launch FM wave in background
ShiftingFMWave wave;
spork ~ wave.play();

// TODO: how to handle global array? better as dur rather than int?
[100, 200, 400, 800] @=> int durations[];


for (1 => int i; i < numberOfSamples; i++) {
    if (samples[i].power.max > samples[i-1].power.max) {
        setGain(bars, numBarVoices, Math.random2f(0.4, 0.8));
        spork ~ play(bars, barVoices);
        <<< i, "power max" >>>;
    }
    if (samples[i].speed.max > samples[i-1].speed.max) {
        spork ~ play(sine, env, sineVoices);
        <<< i, "speed max" >>>;
    }
    if (samples[i].heartRate.max > samples[i-1].heartRate.max) {
        setGain(piano, numPianoVoices, Math.random2f(0.3, 0.6));
        spork ~ play(piano, pianoVoices);
        spork ~ play(piano, pianoVoices);
        spork ~ play(piano, pianoVoices);
        <<< i, "hr max" >>>;
    }
    if (samples[i].cadence.max > samples[i-1].cadence.max) {
        setGain(flute, numFluteVoices, Math.random2f(0.1, 0.2));
        spork ~ play(flute, fluteVoices);
        <<< i, "cadence max" >>>;
    }
    if (samples[i].cadence.current == 0) {
        setGain(mandolin, numMandolinVoices, Math.random2f(0.2, 0.5));
        spork ~ play(mandolin, mandolinVoices);
        <<< i, "cadence = 0" >>>;
    }
    if (samples[i].power.current == 0) {
        <<< i, "power = 0" >>>;
        
        spork ~ play(buff, buffVoices, i, lastDrum);
        i => lastDrum;
    }
    else {
        //<<< i, "" >>>;
    }
    sampleRate::ms => now;
}

// Let sounds fade
10::second => now;


//--------functions----------//


fun void makePatch(SndBuf instrument[], int numVoices, NRev rev) {
    for (0 => int i; i < numVoices; i++) {
        instrument[i] => rev;
    }
}

fun void makePatch(ModalBar instrument[], int numVoices, NRev rev) {
    for (0 => int i; i < numVoices; i++) {
        instrument[i] => rev;
        0 => instrument[i].preset;
    }
}

fun void makePatch(Wurley instrument[], int numVoices, NRev rev) {
    for (0 => int i; i < numVoices; i++) {
        instrument[i] => rev;
    }
}

fun void makePatch(Flute instrument[], int numVoices, NRev rev) {
    for (0 => int i; i < numVoices; i++) {
        instrument[i] => rev;
    }
}

fun void makePatch(SinOsc instrument[], Envelope env[], int numVoices, NRev rev) {
    for (0 => int i; i < numVoices; i++) {
        instrument[i] => env[i] => rev;
        2500::ms => env[i].duration;
    }
}

fun void makePatch(Mandolin instrument[], int numVoices, NRev rev) {
    for (0 => int i; i < numVoices; i++) {
        instrument[i] => rev;
    }
}

fun void makePatch(Mandolin instrument[], NRev rev) {
    for (0 => int i; i < instrument.size(); i++) {
        instrument[i] => rev;
    }
}

fun void play(SndBuf instrument[], int voices[], int i, int lastDrum) {
    getVoice(voices) => int which;
    
    if (which > -1) {
        [0.5, 1.0, 2.0] @=> float rates[];
        
        for (0 => int i; i < 2; i++) {
            if (Math.random2f(0.0, 1.0) > 0.33) {
                rates[Math.random2(0, rates.size()-1)] => instrument[which].rate;
                0 => instrument[which].pos;
                Math.random2f(durations[1], durations[durations.size()-1])::ms => now;
            }
        }
        rates[Math.random2(0, rates.size()-1)] => instrument[which].rate;
        0 => instrument[which].pos;
        
        // fade fm wave in and out
        if (wave.isOff && i - lastDrum > 20 && Math.random2f(0.0, 1.0) > 0.45) { // 55 * 90 ~= 5000 ms 
            //<<< i, "-", lastDrum, "=", i - lastDrum,
            //"(" + Std.ftoa((i - lastDrum) * sampleRate) + " ms)" >>>;
            wave.turnOn(i, lastDrum, sampleRate);
            //<<< wave.isOff >>>;
        }
        0 => voices[which];
    }
}

fun void play(Mandolin instrument[], int voices[]) {
    getVoice(voices) => int which;
    
    if (which > -1) {
        
        Std.mtof(Math.random2(55, 91)) => instrument[which].freq;
        
        1 => instrument[which].pluck;
        durations[Math.random2(0, durations.size()-1)] * 2::ms => now;
        
        Math.random2(10, 20) => int numNotes;
        instrument[which].gain() * 0.6 => float gain => instrument[which].gain;
        
        for (0 => int i; i < numNotes; i++) {
            1 => instrument[which].pluck;
            75::ms => now;    
            1.08 *=> gain => instrument[which].gain;
        }
        durations[Math.random2(0, durations.size()-1)] * 2::ms => now;
        
        if (Math.random2f(0.0, 1.0) > 0.5) {
            setGain(mandolinChord, 
                Math.random2f(instrument[which].gain() - 0.2, instrument[which].gain()));   
            play(mandolinChord);
        }
        
        0 => voices[which]; 
    }
}

fun void play(Mandolin instrument[]) {
    // assign each mandolin its own octave
    for (0 => int i; i < instrument.size(); i++) {
        Std.mtof(Math.random2(55 + 12 * i, 55 + 12 * (i + 1))) => mandolinChord[i].freq;
    }
    for (0 => int i; i < instrument.size(); i++) {
        1 => mandolinChord[i].pluck;
    }
    durations[Math.random2(0, durations.size()-1)] * 2::ms => now;
}

fun void play(Flute instrument[], int voices[]) {
    getVoice(voices) => int which;
    
    if (which > -1) {
        Math.random2(2, 8) => int numNotes;
                
        for (0 => int i; i < numNotes; i++) {
            Std.mtof(Math.random2(72, 96)) => instrument[which].freq;
            
            1 => instrument[which].noteOn;
            durations[Math.random2(0, durations.size()-1)]::ms => now;
            1 => instrument[which].noteOff;    
        }
        0 => voices[which];   
    }
}

fun void play(ModalBar instrument[], int voices[]) {
    getVoice(voices) => int which;
    
    if (which > -1) {
        Math.random2(2, 8) => int numNotes;
        
        for (0 => int i; i < numNotes; i++) {
            Std.mtof(Math.random2(48, 72)) => instrument[which].freq;
            
            1 => instrument[which].strike;
            durations[Math.random2(0, durations.size()-1)]::ms => now;
        }
        for (0 => int i; i < Math.random2(5, 20); i++) {            
            1 => instrument[which].strike;
            100::ms => now;
        }
        
        0 => voices[which];   
    }
}

fun void play(Wurley instrument[], int voices[]) {
    getVoice(voices) => int which;
    
    if (which > -1) {
        Std.mtof(Math.random2(43, 55)) => instrument[which].freq;
        1 => instrument[which].noteOn;
        4000::ms => now;    
        1 => instrument[which].noteOff;
        0 => voices[which];   
    }
}

fun void play(SinOsc instrument[], Envelope env[], int voices[]) {
    getVoice(voices) => int which;
    
    if (which > -1) {
        Math.random2(440, 880) => instrument[which].freq;
        Math.random2f(0.1, 0.3) => instrument[which].gain;
        
        1 => env[which].keyOn;
        env[which].duration() => now;    
        1 => env[which].keyOff;
        env[which].duration() => now;
        
        0 => voices[which]; 
    }
}

fun void setGain(Wurley instrument[], int voices, float gain) {
    for (0 => int i; i < voices; i++) {
        gain => instrument[i].gain;
    }
}

fun void setGain(Mandolin instrument[], int voices, float gain) {
    for (0 => int i; i < voices; i++) {
        gain => instrument[i].gain;
    }
}

fun void setGain(Mandolin instrument[], float gain) {
    for (0 => int i; i < instrument.size(); i++) {
        gain => instrument[i].gain;
    }
}

fun void setGain(ModalBar instrument[], int voices, float gain) {
    for (0 => int i; i < voices; i++) {
        gain => instrument[i].gain;
    }
}

fun void setGain(Flute instrument[], int voices, float gain) {
    for (0 => int i; i < voices; i++) {
        gain => instrument[i].gain;
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


fun float getAverage(float sum, int numItems) {
    return sum / numItems;
}


fun float getMin(float arr[]) {
    arr[0] => float min;
    
    for (1 => int i; i < arr.size(); i++) {
        if (arr[i] < min) {
            arr[i] => min;
        }
    }
    return min;
}


fun float getMax(float arr[]) {
    arr[0] => float max;
    
    for (1 => int i; i < arr.size(); i++) {
        if (arr[i] > max) {
            arr[i] => max;
        }
    }
    return max;
}