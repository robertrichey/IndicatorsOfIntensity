// args
// 40 : 1 : 40 : -0. : 1

SinOsc sin1 => Envelope env1 => SinOsc sin2 => NRev rev => Envelope env2 => Pan2 pan => dac;

//Math.random2f(0.05, 0.1) => sin2.gain;

0.1 => rev.mix;

2 => sin2.sync;

(Std.mtof(Std.atoi(me.arg(0))) * Std.atof(me.arg(1))) => sin2.freq;
Std.atoi(me.arg(2)) => sin1.freq;

Std.atof(me.arg(3)) => pan.pan;

(750 * 4)::ms => env2.duration;

(750 / 2)::ms => dur period; // synchronize to period
period - (now % period) => now;

spork ~ foo(Std.atof(me.arg(4)));

for (0 => int i; i < 8; i++)
{
    env2.keyOn();
    env2.duration() => now;
    
    env2.keyOff();
    env2.duration() => now;
    
    env2.duration() => now;
}

fun void foo(float n)
{
    adc => Gain gain => blackhole;
    sin2 => gain;

    1::ms => env1.duration;
    (750 / n)::ms => dur ringTime;
    Math.random2(2000, 8000) => int mult;
    
    while (true)
    {
        (gain.last() * mult) => float lastGain;
        lastGain => sin1.gain;
        
        if (lastGain > 0.0)
        {
            <<< "Gain: ", lastGain >>>;
        }
        
        env1.keyOn();
        (ringTime - env1.duration()) => now;
        
        env1.keyOff();
        env1.duration() => now;
    }   
}