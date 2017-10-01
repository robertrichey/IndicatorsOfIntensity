// patch
SinOsc sin => dac;
0 => sin.freq;

// create our OSC receiver
OscIn oin;

// create our OSC message
OscMsg msg;

// use port 6449
6449 => oin.port;

// create an address in the receiver
oin.addAddress("/startup");

<<< getTransformation(0, 392, 200, 1600, 0), 
getTransformation(0, 392, 200, 1600, 391) >>>;

// infinite event loop
while (true) {
    // wait for event to arrive
    oin => now;

    // grab the next message from the queue
    while (oin.recv(msg) != 0) { 
        // get values from msg, print
        msg.getString(0) => string hello;
        msg.getInt(1) => int x;
        getTransformation(0.0, 392, 200, 1600, x) => float freq;
        freq => sin.freq;
        <<< "got (via OSC):", hello, x, freq >>>;
    }
}

fun float getTransformation(float a, float b, float c, float d, float x) {
    return (x - a) / (b - a) * (d - c) + c;
}