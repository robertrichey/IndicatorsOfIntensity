// Simple SinOsc-based carrier and modulator
SinOsc modulator => TriOsc carrier => dac;

// Tell the oscillator to interpret input as frequency modulation
2 => carrier.sync; 

// set modulator frequency to 6 Hz
50 => modulator.freq; // 40-200
300 => modulator.gain; // 300-1200

Std.mtof(85) => carrier.freq; // 63-85 MIDI
0.2 => carrier.gain; // 0.1-0.2

0 => int w;

while (true) {
    
    Math.random2(120, 500) => int x => modulator.freq;
    Math.random2(350, 1200) => int y => modulator.gain;
    Math.random2(67, 96) => int z;
    Std.mtof(z) => carrier.freq;

    <<< w++, x, y, z >>>;

    5000::ms => now;
}