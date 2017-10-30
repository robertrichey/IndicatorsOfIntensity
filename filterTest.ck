SndBuf buff => ResonZ filter => dac;
me.dir() + "water.wav" => buff.read;

while (1) {
    Math.random2f(500.0, 2500.0) => filter.freq;
    Math.random2f(5.0, 100.0) => filter.Q;
    //0.3 => filter.gain;
    second => now;
}