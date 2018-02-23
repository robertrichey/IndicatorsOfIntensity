// Simple SinOsc-based carrier and modulator
SinOsc modulator => TriOsc carrier => dac;

// Tell the oscillator to interpret input as frequency modulation
2 => carrier.sync; 

// set modulator frequency to 6 Hz
10.0 => modulator.freq; 
5000 => modulator.gain;

200 => carrier.freq;
1.0 => carrier.gain;

while (true) {
    800::ms => now;
}