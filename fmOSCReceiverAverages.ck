//---------- PATCH ----------//

// NOTE: ENVELOPE REMOVED
// create patch, keep quiet until OSC message is receved
SinOsc modulator => SinOsc carrier => NRev rev => dac;
// Envelope env =>

0.15 => rev.mix;
//1::ms => env.duration;
0 => carrier.gain;

// Tell the oscillator to interpret input as frequency modulation
2 => carrier.sync; 


//---------- VARIABLES ----------//

0.0 => float power;
0.0 => float speed;
0.0 => float heartRate;
0.0 => float cadence;
0 => int numberOfMessages;

// Bad use of globals?
0.0 => float averagePower;
0.0 => float averageSpeed;
0.0 => float averageHeartRate;
0.0 => float averageCadence;


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

// infinite event loop
while (true) {
    // wait for event to arrive
    //env.keyOn();
    oin => now;
    
    // grab the next message from the queue
    while (oin.recv(msg) != 0) { 
        numberOfMessages++;
        
        msg.getInt(0) +=> power;
        msg.getFloat(1) +=> speed;
        msg.getInt(2) +=> heartRate;
        msg.getInt(3) +=> cadence;
        
        getAverage(power, numberOfMessages) => averagePower;
        getAverage(speed, numberOfMessages) => averageSpeed;
        getAverage(heartRate, numberOfMessages) => averageHeartRate;
        getAverage(cadence, numberOfMessages) => averageCadence;
        
        // transform values
        getTransformation(0.0, 450, 200, 800, averagePower) => float watts;
        getTransformation(0.0, 41.4, 0.1, 1, averageSpeed) => float kph;
        getTransformation(78.0, 167, 0, 50, averageHeartRate) => float hr;
        getTransformation(0.0, 103, 0, 1000, averageCadence) => float cad;
        
        // assign 
        watts => carrier.freq;
        kph => carrier.gain;
        hr => modulator.freq;
        cad => modulator.gain;
        
        // print osc msg
        <<< "got (via OSC):", msg.getInt(0), msg.getFloat(1), 
        msg.getInt(2), msg.getInt(3) >>>;
        <<< averagePower, averageSpeed, averageHeartRate, averageCadence >>>; 
    }
    //env.keyOff();
}

// linear transformation (map range [a, b] to [c, d])
// given x between [a, b], return value between [c, d]
fun float getTransformation(float a, float b, float c, float d, float x) {
    return (x - a) / (b - a) * (d - c) + c;
}

fun float getAverage(float x, int y) {
     return x / y;
}