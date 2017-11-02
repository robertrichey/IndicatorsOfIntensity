SndBuf buff => dac;

me.dir() + "heartbeat.wav" => buff.read;

// time loop
while (true) {
    buff.length()::ms => now;
    0 => buff.pos
}