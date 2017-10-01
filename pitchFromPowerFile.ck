//---------- PATCH ----------//

// create patch, keep quiet until OSC message is receved
SinOsc modulator => SinOsc carrier => Envelope env => NRev rev => dac;

0.15 => rev.mix;
10::ms => env.duration;
0.5 => carrier.gain;
6 => modulator.freq;
10 => modulator.gain;

// Tell the oscillator to interpret input as frequency modulation
2 => carrier.sync; 


//---------- File I/O ----------//

FileIO file;
file.open("textfiles/power.txt", FileIO.READ);


//---------- MAIN ----------//

// Get total number of samples and initialize array
file => int numberOfSamples;
Sample samples[numberOfSamples];

int averages[130]; // numberOfSamples = 13281, round to 1300 / 100

0.0 => float power;
//0.0 => float speed;
//0.0 => float heartRate;
//0.0 => float cadence;

// Fill array
for (0 => int i; i < numberOfSamples; i++) {
    file => samples[i].power.current;
}

// Fill array with average of every 100 samples
0 => int index;

for (0 => int i; i < 13000; i++) {
    samples[i].power.current +=> power;
    
    if (i % 100 == 0 && i != 0) {
        Std.ftoi(power / 100) => averages[index++];
        0 => power;
    }
} 

// Assign final index
Std.ftoi(power / 100) => averages[index];

500 => int minPower;
0 => int maxPower;

for (0 => int i; i < averages.cap(); i++) {
    if (averages[i] < minPower) {
        averages[i] => minPower;
        continue;
    }
    if (averages[i] > maxPower) {
        averages[i] => maxPower;
    }
}

// Play sound based on average power over each 100 samples
for (0 => int i; i < averages.cap(); i++) {
    getTransformation(minPower, maxPower, 400, 1600, averages[i]) =>
    carrier.freq;
    
    getTransformation(minPower, maxPower, 1000, 100, averages[i]) =>
    float duration;
    
    <<< averages[i] >>>;
    
    env.keyOn();
    duration::ms => now;
    env.keyOff();
    env.duration() => now;
}

<<< "Done" >>>;

/** 
 * Linear transformation:
 * For a given value between [a, b], return corresponding value between [c, d]
 * source: https://stackoverflow.com/questions/345187/math-mapping-numbers
 */
fun float getTransformation(float a, float b, float c, float d, float x) {
    return (x - a) / (b - a) * (d - c) + c;
}