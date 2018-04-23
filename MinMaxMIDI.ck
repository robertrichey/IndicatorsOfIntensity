/**
 * Primary file for creating sonification
 * Sets up necessary MIDI ports
 * Sets up necessary variables and objects for performing
 * FM waves, voices, and bike sounds (TODO) while generating
 * MIDI data based on a RideData object
 */

//----------- MIDI Setup -----------//


MidiOut marimbaOut;
0 => int port0;

if (!marimbaOut.open(port0)) {
    <<< "Error: MIDI port did not open on port: ", port0 >>>;
    me.exit();
}

MidiOut fluteOut;
1 => int port1;

if (!fluteOut.open(port1)) {
    <<< "Error: MIDI port did not open on port: ", port1 >>>;
    me.exit();
}

MidiOut guitarOut1;
2 => int port2;

if (!guitarOut1.open(port2)) {
    <<< "Error: MIDI port did not open on port: ", port2 >>>;
    me.exit();
}

MidiOut guitarOut2;
3 => int port3;

if (!guitarOut2.open(port3)) {
    <<< "Error: MIDI port did not open on port: ", port3 >>>;
    me.exit();
}

MidiOut guitarOut3;
4 => int port4;

if (!guitarOut3.open(port4)) {
    <<< "Error: MIDI port did not open on port: ", port4 >>>;
    me.exit();
}

MidiOut pianoOut1;
5 => int port5;

if (!pianoOut1.open(port5)) {
    <<< "Error: MIDI port did not open on port: ", port5 >>>;
    me.exit();
}

MidiOut pianoOut2;
6 => int port6;

if (!pianoOut2.open(port6)) {
    <<< "Error: MIDI port did not open on port: ", port6 >>>;
    me.exit();
}

MidiOut pianoOut3;
7 => int port7;

if (!pianoOut3.open(port7)) {
    <<< "Error: MIDI port did not open on port: ", port7 >>>;
    me.exit();
}

// NOTE: may need to change to 8 if interface not in use
MidiOut drumOut;
8 => int port8;

if (!drumOut.open(port8)) {
    <<< "Error: MIDI port did not open on port: ", port8 >>>;
    me.exit();
}


//------- SET UP OBJECTS, VARIABLES TO PLAY WITH MIDI -------//

// Patch for sine waves
5 => int numSineVoices;
int sineVoices[numSineVoices];

SinOsc sine[numSineVoices];
Envelope env[numSineVoices];

makePatch(sine, env);


// Bools for checking if an instrument is playing
1 => int drumIsOff;
1 => int pianoIsOff;
1 => int marimbaIsOff;
1 => int fluteIsOff;
1 => int guitarIsOff;

// Use cycling data set
RideData data;
data.getSamples() @=> Sample samples[];
samples.size() => int numberOfSamples;

// Set length of piece
960000 => float totalDuration;
totalDuration / numberOfSamples => float sampleRate;
 
// Set durations for MIDI instruments
[100, 200, 400, 800] @=> int durations[];


// Create and launch FM waves in background

ShiftingFMWave1 wave;
data.getGrains(5) @=> wave.grains;
totalDuration => wave.totalDuration;
spork ~ wave.play();

ShiftingFMWave2 wave2;
data.getGrains(3) @=> wave2.grains;
totalDuration => wave2.totalDuration;
spork ~ wave2.play();

ShiftingFMWave3 wave3;
data.getGrains(2) @=> wave3.grains;
totalDuration => wave3.totalDuration;
spork ~ wave3.play();

1.0 => float waveChance;
spork ~ setWaveChance();


// Create and launch voices in background

PowerZones zones;
data.getSamples() @=> zones.samples;
totalDuration => zones.totalDuration;
spork ~ zones.play();


//----------- MAIN LOOP -----------//

0 => int lastDrum;

for (1 => int i; i < numberOfSamples; i++) {
    if (samples[i].power.max > samples[i-1].power.max && marimbaIsOff) {
        spork ~ playMarimba();
        <<< i, "power max" >>>;
    }
    if (samples[i].speed.max > samples[i-1].speed.max) {
        spork ~ playSine(sine, env, sineVoices);
        <<< i, "speed max" >>>;
    }
    if (samples[i].heartRate.max > samples[i-1].heartRate.max && pianoIsOff) {
        spork ~ playPiano();
        <<< i, "hr max" >>>;
    }
    if (samples[i].cadence.max > samples[i-1].cadence.max && fluteIsOff) {
        spork ~ playFlute();
        <<< i, "cadence max" >>>;
    }
    if (samples[i].cadence.current == 0 && guitarIsOff) {
        spork ~ playGuitar();
        <<< i, "cadence = 0" >>>;
    }
    if (samples[i].power.current == 0) {
        <<< i, "power = 0" >>>;
        
        if (drumIsOff) {
            i - lastDrum => int numPassedSamples;
            spork ~ playDrum(numPassedSamples);
        }
        
        i => lastDrum;
    }
    else {
        //<<< i, "" >>>;
    }
    sampleRate::ms => now;
}

// Let sounds fade
10::second => now;

// END MAIN


//--------functions----------//


/**
 * Connect SinOsc and Envelope objects to dac
 */
fun void makePatch(SinOsc instrument[], Envelope env[]) {
    for (0 => int i; i < instrument.size(); i++) {
        instrument[i] => env[i] => dac;
        2500::ms => env[i].duration;
    }
}

/**
 * Play between 1 and 3 drum hits, occasionally follow with 1 or more FM waves
 */
fun void playDrum(int count) {
    0 => drumIsOff;
    
    for (0 => int i; i < 2; i++) {
        if (Math.randomf() > 0.33) {
            Math.random2(72, 74) => int note;
            Math.random2(70, 115) => int velocity;
            
            MIDInote(drumOut, 1, note, velocity);
            Math.random2f(durations[1], durations[durations.size()-1]) * Math.random2f(1.0, 2.5)::ms => now;
            MIDInote(drumOut, 0, note, velocity);                
        } 
    }
    
    Math.random2(72, 74) => int note;
    Math.random2(90, 127) => int velocity;
    
    setWavePan(note) => float wavePan;
    
    MIDInote(drumOut, 1, note, velocity);
    
    // fade fm wave in and out, 55% chance to play
    if (wave.isOff && count > 30 && count < 12500 && Math.randomf() > 0.45) {
        //<<< i, "-", lastDrum, "=", i - lastDrum, ((i - lastDrum) * sampleRate) >>>;
        //, "(" + Std.ftoa((i - lastDrum) * sampleRate) + " ms)" >>>;
        Event e;
        
        0 => int wave2isOn;
        0 => int wave3isOn;
        
        count * sampleRate => float ringTime; // elapsed time between previous two drum hits 
        
        // Always turn on one FM wave
        spork ~ wave.turnOn(ringTime, wavePan, e);
        
        // Sometimes use additional FM waves
        if (Math.randomf() > getWaveChance()) {
            1 => wave2isOn;
            spork ~ wave2.turnOn(ringTime, Math.random2f(-0.9, 0.9), e);
        }
        if (Math.randomf() > getWaveChance()) {
            1 => wave3isOn;
            spork ~ wave3.turnOn(ringTime, Math.random2f(-0.9, 0.9), e);
        }
        e => now;
        
        if (wave2isOn) {
            e => now;
            0 => wave2isOn;
        }
        if (wave3isOn) {
            e => now;
            0 => wave3isOn;
        }
    }

    MIDInote(drumOut, 0, note, velocity);                
    
    1 => drumIsOff;
}

/**
 * Returns a float to be used for setting the pan value of an FM wave
 */
fun float setWavePan(int note) {
    float pan;
    
    if (note == 72) {
        0 => pan;
    }
    else if (note == 73) {
        -0.4 => pan;
    }
    else {
        0.4 => pan;
    }
    return pan;
}

/**
 * Gradually lowers waveChance to 0.25 and returns it to its starting point over totalDuration milliseconds
 */
fun void setWaveChance() {
    0.25 => float target;
    100.0 => float grain;
    totalDuration / 4 / grain => float count;
    (waveChance - target) / count => float increment;
    
    (count * grain)::ms => now;
    
    for (0 => int i; i < count; i++) {
        increment -=> waveChance;
        grain::ms => now;
    }   
    for (0 => int i; i < count; i++) {
        increment +=> waveChance;
        grain::ms => now;
    }    
    (count * grain)::ms => now;
}

/**
 * Returns current value of waveChance
 */
fun float getWaveChance() {
    return waveChance;
}

/**
 * Play a SinOsc object if available
 */
fun void playSine(SinOsc instrument[], Envelope env[], int voices[]) {
    getVoice(voices) => int which;
    
    if (which > -1) {
        Math.random2(440, 880) => instrument[which].freq;
        Math.random2f(0.15, 0.25) => instrument[which].gain;
        
        1 => env[which].keyOn;
        env[which].duration() => now;    
        1 => env[which].keyOff;
        env[which].duration() => now;
        
        0 => voices[which]; 
    }
}

/**
 * Play a rapid series of notes on one pitch, occasionally end with a chord
 */
fun void playGuitar() {
    0 => guitarIsOff;
    
    Math.random2(55, 84) => int note;
    Math.random2(50, 70) => int velocity;
    
    MIDInote(guitarOut1, 1, note, velocity);
    durations[Math.random2(0, durations.size()-1)] * 2::ms => now;
    MIDInote(guitarOut1, 0, note, velocity);
    
    Math.random2(10, 20) => int numNotes;
    Std.ftoi(velocity * 0.6) => velocity;
    
    for (0 => int i; i < numNotes; i++) {
        MIDInote(guitarOut1, 1, note, velocity);
        75::ms => now; 
        MIDInote(guitarOut1, 0, note, velocity);
           
        Std.ftoi(velocity * 1.08) => velocity;
    }
    durations[Math.random2(0, durations.size()-1)] * 2::ms => now;
    MIDInote(guitarOut1, 0, note, velocity);
    
    if (Math.randomf() > 0.45) {   
        playGuitarChord();
    }
    
    1 => guitarIsOff;
}

/**
 * Plays a three-voice guitar chord of random duration
 */
fun void playGuitarChord() {
    // assign each note its own octave
    Math.random2(48, 60) => int note1;
    Math.random2(60, 72) => int note2;
    Math.random2(72, 84) => int note3;
    
    Math.random2(75, 95) => int velocity;
    
    MIDInote(guitarOut1, 1, note1, velocity);
    MIDInote(guitarOut2, 1, note2, velocity);
    MIDInote(guitarOut3, 1, note3, velocity);
    
    durations[Math.random2(0, durations.size()-1)] * Math.random2(2, 3)::ms => now;
    
    MIDInote(guitarOut1, 0, note1, velocity);
    MIDInote(guitarOut2, 0, note2, velocity);
    MIDInote(guitarOut3, 0, note3, velocity);
}

/**
 * Plays between 2 and 8 notes on flute with occasional trills
 */
 fun void playFlute() {
    0 => fluteIsOff;  
    
    Math.random2(2, 8) => int numNotes;
    Math.random2(60, 127) => int velocity;
    
    for (0 => int i; i < numNotes; i++) {
        // occasionally perform a trill halfway through passage
        if (i == numNotes / 2 && Math.randomf() > 0.6) {
            trill(velocity);
        }
        Math.random2(72, 96) => int note;
        
        MIDInote(fluteOut, 1, note, velocity);
        durations[Math.random2(0, durations.size()-1)]::ms => now;
        MIDInote(fluteOut, 0, note, velocity);
    }
    
    // occasionally end w/ a trill
    if (Math.randomf() > 0.66) {
        trillFade(velocity);
    }
    
    1 => fluteIsOff;
}

/**
 * Plays a trill in the flute
 */
fun void trill(int velocity) {
    Math.random2(72, 96) => int note;
    Math.random2(1, 5) => int interval;
    
    for (0 => int i; i < 5; i++) {
        if (i % 2 == 0) {
            MIDInote(fluteOut, 1, note, velocity);
        }
        else {
            MIDInote(fluteOut, 1, note + interval, velocity);
        }
        durations[0]::ms => now;
        
        MIDInote(fluteOut, 0, note, velocity);
        MIDInote(fluteOut, 0, note + interval, velocity);
    }
}

/**
 * Plays a trill that gradually fades
 */
fun void trillFade(int velocity) {
    Math.random2(72, 96) => int note;
    Math.random2(1, 5) => int interval;
    
    for (0 => int i; i < 13; i++) {
        if (i % 2 == 0) {
            MIDInote(fluteOut, 1, note, velocity);
        }
        else {
            MIDInote(fluteOut, 1, note + interval, velocity);
        }
        durations[0]::ms => now;
                
        MIDInote(fluteOut, 0, note, velocity);
        MIDInote(fluteOut, 0, note + interval, velocity);
        5 -=> velocity;
    }
}

/**
 * Plays between 2 and 8 notes on marimba
 */
fun void playMarimba() {
    0 => marimbaIsOff;
    
    Math.random2(2, 8) => int numNotes;
    Math.random2(95, 127) => int velocity;
    
    for (0 => int i; i < numNotes; i++) {
        Math.random2(36, 72) => int note; 
        MIDInote(marimbaOut, 1, note, velocity); 
        durations[Math.random2(0, durations.size()-1)]::ms => now;
        MIDInote(marimbaOut, 0, note, velocity); 
        
    }
    Math.random2(36, 72) => int note; 
    for (0 => int i; i < Math.random2(5, 20); i++) {            
        MIDInote(marimbaOut, 1, note, velocity); 
        100::ms => now;   
    }
    durations[durations.size()-1] * 2::ms => now;
    MIDInote(marimbaOut, 0, note, velocity); 
    
    1 => marimbaIsOff;  
}

/**
 * Plays a three-voice piano chord for four seconds
 */
fun void playPiano() {   
    0 => pianoIsOff;
    
    Math.random2(48, 55) => int note1;
    Math.random2(48, 55) => int note2;
    Math.random2(48, 55) => int note3;
    
    Math.random2(90, 115) => int velocity;
    
    MIDInote(pianoOut1, 1, note1, velocity);
    MIDInote(pianoOut2, 1, note2, velocity);
    MIDInote(pianoOut3, 1, note3, velocity);
    
    4000::ms => now; // TODO: elaborate on duration?
    
    MIDInote(pianoOut1, 0, note1, velocity);
    MIDInote(pianoOut2, 0, note2, velocity);
    MIDInote(pianoOut3, 0, note3, velocity);
    
    1 => pianoIsOff;
}

/**
 * Utility function to send MIDI out notes
 */
fun void MIDInote(MidiOut mout, int onOff, int note, int velocity) {
    MidiMsg msg;
    
    if(onOff == 0) {
        128 => msg.data1;
    }
    else {
        144 => msg.data1;
    }
    note => msg.data2;
    velocity => msg.data3;
    mout.send(msg);
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