// create our OSC receiver
OscIn oin;

// create our OSC message
OscMsg msg;

// use port 6449
6449 => oin.port;

// create an address in the receiver
oin.addAddress("/startup");

// infinite event loop
while (true) {
    // wait for event to arrive
    oin => now;

    // grab the next message from the queue. 
    while (oin.recv(msg) != 0) { 
        // get values from msg, print
        msg.getString(0) => string hello;
        msg.getInt(1) => int x;
        <<< "got (via OSC):", hello, x >>>;
    }
}
