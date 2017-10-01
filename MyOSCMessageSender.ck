OscOut xmit;

6449 => int port;
xmit.dest("localhost", port);

while (true) {
    xmit.start("/myChucK/OSCNote");
    
    Math.random2(48,80) =>int note;
    Math.random2f(0.1,1.0)=>float velocity;
    "Hi out there!!" => string message;
    
    note => xmit.add;
    velocity => xmit.add;
    message => xmit.add;
    
    xmit.send();
    
    0.2 :: second => now;
}

