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


//---------- PATCH ----------//

5 => int numSineVoices;
int sineVoices[numSineVoices];
3 => int numBuffVoices;
int buffVoices[numBuffVoices];

SndBuf2 buff[numBuffVoices]; // filter, multiple sounds, keep track of duration between drums
Pan2 pan[numBuffVoices];

2.0 => buff[0].rate;
0.5 => buff[1].rate;
1.0 => buff[2].rate;


-0.4 => pan[0].pan;
0 => pan[1].pan;
0.4 => pan[2].pan;

SinOsc sine[numSineVoices];
Envelope env[numSineVoices]; // for sine waves

// Connect UGens to dac
makePatch(buff, pan);
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
<<< sampleRate >>>;


// TODO: how to handle global array? better as dur rather than int?
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
            spork ~ playDrum(buff, buffVoices, i, lastDrum);
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


// TODO: Document
fun void makePatch(SndBuf2 instrument[], Pan2 pan[]) {    
    for (0 => int i; i < instrument.size(); i++) {
        instrument[i] => pan[i] => dac;
        me.dir() + "bass_drum.wav" => buff[i].read;
        buff[i].samples() => buff[i].pos;
    }
}

fun void makePatch(SinOsc instrument[], Envelope env[]) {
    for (0 => int i; i < instrument.size(); i++) {
        instrument[i] => env[i] => dac;
        2500::ms => env[i].duration;
    }
}

fun void playDrum(SndBuf2 instrument[], int voices[], int i, int lastDrum) {
    0 => drumIsOff;
    
    [0.5, 1.0, 2.0] @=> float rates[];
    setDrumGain(instrument);
    
    for (0 => int i; i < 2; i++) {
        getVoice2(voices) => int which;
        
        if (which > -1) {
            if (Math.randomf() > 0.33) {
                //rates[Math.random2(0, rates.size()-1)] => buff[which].rate;
                0 => buff[which].pos;
                Math.random2f(durations[1], durations[durations.size()-1]) * 1.5::ms => now;
            }
            0 => voices[which]; 
        }
    }
    getVoice2(voices) => int which;
    
    if (which > -1) {
        //rates[Math.random2(0, rates.size()-1)] => buff[which].rate;
        0 => buff[which].pos;
        
        // fade fm wave in and out, 55% chance to play
        if (wave.isOff && i - lastDrum > 30 && Math.random2f(0.0, 1.0) > 0.45) {
            //<<< i, "-", lastDrum, "=", i - lastDrum, ((i - lastDrum) * sampleRate) >>>;
            //, "(" + Std.ftoa((i - lastDrum) * sampleRate) + " ms)" >>>;
            Event e;
            Event e2;
            Event e3;
            
            0 => int wave2isOn;
            0 => int wave3isOn;

            (i-lastDrum) * sampleRate => float ringTime; // elapsed time between previous two drum hits 
            
            // Always turn on one FM wave
            spork ~ wave.turnOn(ringTime, pan[which].pan(), e);
            
            // Sometimes use additional FM waves
            if (Math.randomf() > 0.5) {
                1::ms => now;
                1 => wave2isOn;
                spork ~ wave2.turnOn(ringTime, wave.getPan() * -1, e2);
            }
            if (Math.randomf() > 0.5) {
                1::ms => now;
                1 => wave3isOn;
                spork ~ wave3.turnOn(ringTime, wave.getPan() * -1, e3);
            }
            e => now;
            
            if (wave2isOn) {
                e2 => now;
                0 => wave2isOn;
            }
            if (wave3isOn) {
                e3 => now;
                0 => wave3isOn;
            }
        }
        
        // TODO: accidental copy/paste? Remove?
        Math.random2f(durations[1], durations[durations.size()-1]) * 1.5::ms => now;
        0 => voices[which]; 
    }
    
    1 => drumIsOff;
}

fun void setDrumGain(SndBuf2 buff[]) {
    for (0 => int i; i < buff.size(); i++) {
        Math.random2f(2.0, 3.0) => buff[i].gain;
    }
}

fun void playWave(ShiftingFMWave1 w) {
    Event e;
    //w.turnOn();
    e => now;
}

fun void playSine(SinOsc instrument[], Envelope env[], int voices[]) {
    getVoice(voices) => int which;
    
    if (which > -1) {
        Math.random2(440, 880) => instrument[which].freq;
        Math.random2f(0.2, 0.4) => instrument[which].gain;
        
        1 => env[which].keyOn;
        env[which].duration() => now;    
        1 => env[which].keyOff;
        env[which].duration() => now;
        
        0 => voices[which]; 
    }
}

fun void playGuitar() {
    0 => guitarIsOff;
    
    Math.random2(55, 91) => int note;
    Math.random2(60, 80) => int velocity;
    
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
    
    if (Math.random2f(0.0, 1.0) > 0.45) {   
        playGuitarChord();
    }
    
    1 => guitarIsOff;
}

fun void playGuitarChord() {
    // assign each note its own octave
    Math.random2(55, 67) => int note1;
    Math.random2(67, 79) => int note2;
    Math.random2(79, 91) => int note3;
    
    Math.random2(80, 100) => int velocity;
    
    MIDInote(guitarOut1, 1, note1, velocity);
    MIDInote(guitarOut2, 1, note2, velocity);
    MIDInote(guitarOut3, 1, note3, velocity);
    
    durations[Math.random2(0, durations.size()-1)] * Math.random2(2, 3)::ms => now;
    
    MIDInote(guitarOut1, 0, note1, velocity);
    MIDInote(guitarOut2, 0, note2, velocity);
    MIDInote(guitarOut3, 0, note3, velocity);
}

// TODO: handle velocity/gain/volume
fun void playFlute() {
    0 => fluteIsOff;  
    
    Math.random2(2, 8) => int numNotes;
    Math.random2(60, 127) => int velocity;
    
    for (0 => int i; i < numNotes; i++) {
        // occasionally perform a trill halfway through passage
        if (i == numNotes / 2 && Math.random2f(0.0, 1.0) > 0.6) {
            trill(velocity);
        }
        Math.random2(72, 96) => int note;
        
        MIDInote(fluteOut, 1, note, velocity);
        durations[Math.random2(0, durations.size()-1)]::ms => now;
        MIDInote(fluteOut, 0, note, velocity);
    }
    
    // occasionally end w/ a trill
    if (Math.random2f(0.0, 1.0) > 0.66) {
        trillFade(velocity);
    }
    
    1 => fluteIsOff;
}

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
        5 -=> velocity; // TODO: doesn't work - how to affect volume?
    }
}

fun void playMarimba() {
    0 => marimbaIsOff;
    
    Math.random2(2, 8) => int numNotes;
    Math.random2(80, 127) => int velocity;
    
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

// utility function to send MIDI out notes
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

fun int getVoice(int voices[]) {
    for (int i; i < voices.size(); i++) { 
        if (voices[i] == 0) {            
            1 => voices[i];
            return i;
        }
    }
    return -1;
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