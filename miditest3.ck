4 => int numberOfVoices;

// MIDI out setup, make a MidiOut object, open it on a device 
MidiOut mout[numberOfVoices];

// MIDI Port
int port[numberOfVoices];

// try to open that port, fail gracefully
for (0 => int i; i < numberOfVoices; i++) {
    if(!mout[i].open(port[i])) {
        <<< "Error: MIDI port did not open on port: ", port[i] >>>;
        me.exit();
    }
}
// Make a MIDI msg holder for sending

// loop
30 => int count;

while(count > 0) {
    MidiMsg msg;
    
    Math.random2(0, 3) => int which;
    <<< which >>>;
    Math.random2(60,100) => int note; 
    Math.random2(30,127) => int velocity;
    MIDInote(msg, which, 1, note, velocity); 
    0.1::second => now; 
    MIDInote(msg, which, 0, note, velocity); 
    0.1::second => now;
    count--;
}

// utility function to send MIDI out notes
fun void MIDInote(MidiMsg msg, int which, int onOff, int note, int velocity) {
    <<< which >>>;
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