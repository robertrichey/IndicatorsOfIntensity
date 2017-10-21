5 => int numberOfVoices;

// MIDI out setup, make a MidiOut object, open it on a device 
MidiOut mout[numberOfVoices];

for (0 => int i; i < numberOfVoices; i++) {
    // try to open that port, fail gracefully
    if(!mout[i].open(i)) {
        <<< "Error: MIDI port did not open on port: ", i >>>;
        me.exit();
    }
}
// Make a MIDI msg holder for sending
MidiMsg msg;

// loop
int which;

for (60 => int i; i < 178; i++) {
    Math.random2(0, 3) => which;
    //Math.random2(60,72) => int note; 
    Math.random2(30,60) => int velocity;
        <<< i >>>;// 60 62 64 65 67 69 71 72  

    MIDInote(1, i, velocity); 
    10.1::second => now; 
    MIDInote(0, i, velocity); 
    0.1::second => now;
} 


// utility function to send MIDI out notes
fun void MIDInote(int onOff, int note, int velocity) {
    if(onOff == 0) {
        128 => msg.data1;
    }
    else {
        144 => msg.data1;
    } 
    note => msg.data2;
    velocity => msg.data3; 
    mout[3].send(msg);
}