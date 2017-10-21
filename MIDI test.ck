4 => int numberOfVoices;

// MIDI out setup, make a MidiOut object, open it on a device 
MidiOut mout[numberOfVoices];

// MIDI Port
int port[numberOfVoices];

for (0 => int i; i < numberOfVoices; i++) {
    // try to open that port, fail gracefully
    if(!mout[i].open(i)) {
        <<< "Error: MIDI port did not open on port: ", port >>>;
        me.exit();
    }
}
// Make a MIDI msg holder for sending
MidiMsg msg;

// loop
500 => int count;
int which;

while(count > 0) {
    Math.random2(0, 3) => which;
    Math.random2(60,100) => int note; 
    Math.random2(30,127) => int velocity;
    MIDInote(1, note, velocity); 
    0.5::second => now; 
    MIDInote(0, note, velocity); 
    0.25::second => now;
    count--;
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
    mout[which].send(msg);
}