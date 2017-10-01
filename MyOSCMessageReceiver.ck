OscIn oin;
6449 => oin.port;
OscMsg message;

oin.listen("/myChucK/OSCNote");

Rhodey piano => dac;

while (true) {
    oin => now; // message is an event
    
    while (oin.recv(message) != 0) {
        message.getInt(0) => int note;
        message.getFloat(1) => float velocity;
        message.getString(2) => string greeting;
        
        Std.mtof(note) => piano.freq;
        velocity => piano.gain;
        velocity => piano.noteOn;
        
        <<< greeting, note, velocity >>>;
    }
}