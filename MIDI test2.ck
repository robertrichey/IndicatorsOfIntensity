4 => int numberOfVoices;

// MIDI out setup, make a MidiOut object, open it on a device 
MidiOut mout[numberOfVoices];

// MIDI Port
int port[numberOfVoices];

// try to open that port, fail gracefully
for (0 => int i; i < numberOfVoices; i++)
if(!mout[i].open(port[i])) {
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}
// Make a MIDI msg holder for sending
MidiMsg msg;

// loop
while(true) {
    Math.random2(60,100) => int note; 
    Math.random2(30,127) => int velocity;
    MIDInote(1, note, velocity); 
    0.1::second => now; 
    MIDInote(0, note, velocity); 
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
    mout.send(msg);
}