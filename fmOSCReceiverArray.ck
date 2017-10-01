//---------- PATCH ----------//

// create patch, keep quiet until OSC message is receved
SinOsc modulator => SinOsc carrier => Envelope env => NRev rev => dac;

0.15 => rev.mix;
1::ms => env.duration;
0 => carrier.gain;

// Tell the oscillator to interpret input as frequency modulation
2 => carrier.sync; 


//---------- OSC ----------//

// create our OSC receiver
OscIn oin;

// create our OSC message
OscMsg msg;

// use port 6449
6449 => oin.port;

// create an address in the receiver
oin.addAddress("/startup");


//---------- MAIN ----------//

oin => now;
oin.recv(msg);

msg.getInt(0) => int numberOfSamples;
Sample samples[numberOfSamples];
<<< samples.cap() >>>;

0.0 => float power;
0.0 => float speed;
0.0 => float heartRate;
0.0 => float cadence;

0 => int i;
0 => int transferCompleted;

while (!transferCompleted) {
    oin => now;
    while (oin.recv(msg) != 0) { 
        if (msg.getString(0) == "done") {
            1 => transferCompleted;
        }
        
        msg.getInt(0) => samples[i].elapsedTime;
        msg.getFloat(1) => samples[i].distance;
        msg.getInt(2) => samples[i].power.current;
        msg.getFloat(3) => samples[i].speed.current;
        msg.getInt(4) => samples[i].hr.current;
        msg.getInt(5) => samples[i].cadence.current;
        
        /*
        <<< samples[i].elapsedTime,
        samples[i].distance,
        samples[i].power.current,
        samples[i].speed.current,
        samples[i].hr.current,
        samples[i].cadence.current
        >>>;
        */
        i++;
    }
}

<<< i, samples[5].elapsedTime,
    samples[5].distance,
    samples[5].power.current,
    samples[5].speed.current,
    samples[5].hr.current,
    samples[5].cadence.current
>>>;

<<< "Done" >>>;

/** 
 * Linear transformation:
 * For a given value between [a, b], return corresponding value between [c, d]
 * source: https://stackoverflow.com/questions/345187/math-mapping-numbers
 */
fun float getTransformation(float a, float b, float c, float d, float x) {
    return (x - a) / (b - a) * (d - c) + c;
}