
fun void playVoices() {
    8 => int numVoices;
    SinOsc s[numVoices];
    Envelope env[numVoices];
    NRev r[numVoices];
    500::ms => dur ramp;
    
    
    for (int i; i < numVoices; i++)
    {
        0.1 => s[i].gain;
        ramp => env[i].duration;
        s[i] => env[i] => r[i] => dac;
        env[i].keyOn();
    }
    
    1000::ms => now;
    
    for (int i; i < numVoices; i++)
    {
        env[i].keyOff();
    }
    env[0].duration => now;
}

while (true)
{
    Std.rand2(80, 4000)::ms => dur d;
    spork~ playSine(d);
    //spork~ playSine(d);
    //spork~ playSine(d);
    250::ms => now;
}

fun void playSine(dur ring)
{
    getFreeVoice() => int which;
    if (which > -1)
    {
        <<< which >>>;
        Std.rand2f(200., 2000.) => s[which].freq;
        env[which].keyOn();
        ramp => now;
        ring => now;
        env[which].keyOff();
        ramp => now;
        0 => SinVoice[which];      
    }
}

fun int getFreeVoice()
{
    for (int i; i < numVoices; i++)
    { 
        if (SinVoice[i] == 0)
        {            
            1 => SinVoice[i];
            return i;
        }
    }
    <<< 999999999 >>>;
    return -1;//if no voice is free
}