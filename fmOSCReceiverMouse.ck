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

0 => int transferCompleted;

// infinite event loop
while (!transferCompleted) {
    // wait for event to arrive
    env.keyOn();
    oin => now;
    
    // grab the next message from the queue
    while (oin.recv(msg) != 0) {
        if (msg.getString(0) == "done") {
            1 => transferCompleted;
        } 
        // transform values from msg
        getTransformation(0.0, 450, 200, 800, msg.getInt(0)) => float watts;
        getTransformation(0.0, 41.4, 0.1, 1, msg.getFloat(1)) => float kph;
        getTransformation(78.0, 167, 0, 1000, msg.getInt(2)) => float hr;
        getTransformation(0.0, 103, 0, 1000, msg.getInt(3)) => float cad;
        
        // assign 
        watts => carrier.freq;
        kph => carrier.gain;
        hr => modulator.freq;
        cad => modulator.gain;
        
        // print osc msg
        <<< "got (via OSC):", msg.getInt(0), msg.getFloat(1), 
        msg.getInt(2), msg.getInt(3) >>>;
    }
    env.keyOff();
}

// linear transformation - map range [a, b] to [c, d]
// given x between [a, b], return value between [c, d]
fun float getTransformation(float a, float b, float c, float d, float x) {
    return (x - a) / (b - a) * (d - c) + c;
}