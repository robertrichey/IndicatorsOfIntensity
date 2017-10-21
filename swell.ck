SinOsc s => dac;

0.2 => s.gain;

swell(s, 440, 880, 1);


// swell function, operates on any type of UGen
fun void swell(SinOsc osc, float begin, float end, float grain) { 
    float val;
    
    // swell up volume
    for (begin => val; val < end; grain +=> val) {
        val => osc.freq;
        0.01 :: second => now;
    }
    // swell down volume
    while (val > begin) {
        val => osc.freq;
        grain -=> val;
        0.01:: second => now;
    } 
}
