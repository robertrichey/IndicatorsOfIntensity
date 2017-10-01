//---------- PATCH ----------//

// create patch, keep quiet until OSC message is receved
SinOsc modulator => SinOsc carrier => NRev rev => dac;
// Envelope env =>

0.15 => rev.mix;
0.3 => carrier.gain;
6 => modulator.freq;
10 => modulator.gain;

// Tell the oscillator to interpret input as frequency modulation
2 => carrier.sync; 


//---------- File I/O ----------//

FileIO file;
file.open("power.txt", FileIO.READ);


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

// Find min and max power
for (0 => int i; i < averages.cap(); i++) {
    if (averages[i] < minPower) {
        averages[i] => minPower;
        continue;
    }
    if (averages[i] > maxPower) {
        averages[i] => maxPower;
    }
}

//<<< minPower, maxPower >>>;

// Play sound based on average power over each 100 samples
getTransformation(minPower, maxPower, 200, 3200, averages[0]) => 
float current;

for (0 => int i; i < averages.cap() - 1; i++) {
    getTransformation(minPower, maxPower, 200, 3200, averages[i]) => 
    float startFreq;
    
    getTransformation(minPower, maxPower, 400, 3200, averages[i + 1]) => 
    float endFreq;
    
    <<< averages[i], averages[i + 1] >>>;
    
    //spork ~ 
    shiftPitch(startFreq, endFreq, 3000);
    //500::ms => now;
    
    /* // Envelope stuff
    <<< averages[i] >>>;
    d => env.duration;
    env.keyOn();
    d => now;
    env.keyOff();
    env.duration() => now;
    */
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

fun void shiftPitch(float start, float finish, int duration) {
    finish - start => float diff;
    diff / duration => float grain;
    
    for (0 => int i; i < duration; i++) {
        grain +=> current;
        current => carrier.freq;
        1::ms => now;
    }
    finish => carrier.freq;
}