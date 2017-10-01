5.0 => float x;
Std.ftoi(x)/2 => int y;
<<< y >>>;

20 => int numberOfVoices;
SinOsc sine[numberOfVoices];

for (0 => int i; i < numberOfVoices; i++) {
    sine[i] => dac;
    0.05 => sine[i].gain;
}

while (true) {
    for (0 => int i; i < numberOfVoices; i++) {
        Math.random2(200, 3200) => sine[i].freq;
    }
    
    5::second => now;
}