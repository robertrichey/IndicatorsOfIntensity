
// synchronize to period (use for otf programming)
750::ms => dur period; // quarter note at bpm = 80
period - (now % period) => now;


// UGens
3 => int numVoices;
SndBuf buff[numVoices]; // for testing
PitShift pShift[numVoices];
Envelope env[numVoices];
Gain input[numVoices];
Delay del[numVoices];
Pan2 pan[numVoices];

// pan hard left/right for now
-1.0 => pan[1].pan;
1.0 => pan[2].pan;

// for use with envelope
dur rampTime;

// sound chain
for (0 => int i; i < numVoices; i++)
{
    buff[i] => pShift[i] => env[i] => input[i] => pan[i] => dac;
    input[i] => del[i] => pan[i] => dac;
    del[i] => del[i];
  
    // set UGen parameters    
    me.dir() + "test6a.aiff" => buff[i].read;
    
    1.0 => pShift[i].mix;
    
    1::ms => rampTime => env[i].duration;

    0.4 => input[i].gain;
}

// for testing
//0 => input[0].gain;
//0 => input[1].gain;
//0 => input[2].gain;

// establish durations based on metronome tempo
80 => int bpm;

(60000 / bpm)::ms => dur quarter;
quarter * 4 => dur whole;
quarter * 2 => dur half;
quarter / 2 => dur eighth;
quarter / 4 => dur sixteenth;

quarter / 3 => dur triplet;
quarter / 6 => dur sextuplet;
triplet * 2 => dur quarterNoteTriplet;
triplet * 4 => dur halfNoteTriplet;

quarter / 5 => dur fives;
quarter / 10 => dur tens;

[whole, half, quarter, eighth, sixteenth, 
 triplet, sextuplet, quarterNoteTriplet, halfNoteTriplet, fives, 
 tens] @=> dur durs[];

// set delay lines
// 7 8 2   8 8 9   9 5 0   3 0 0
setDelay(0, 0.68, durs[7]);
setDelay(1, 0.68, durs[8]);
setDelay(2, 0.68, durs[2]);

// set pitch shifters
spork ~ setShiftRate(0, durs[9]);
spork ~ setShiftRate(1, durs[9]);
spork ~ setShiftRate(2, durs[9]);

// main loop
buff[0].length() => now;
20000::ms => now;

// set delay gain and duration
fun void setDelay(int which, float gain, dur delay)
{
    gain => del[which].gain;
    delay => del[which].max => del[which].delay;
}

// shift pitch between 5ths, octaves
fun void setShiftRate(int which, dur duration)
{
    while (true) 
    {
        // float for determining when to shift pitch
        Math.random2f(0.0, 1.0) => float chance;
        
        if (chance < 0.1) 
        {
            2.0 => pShift[which].shift;
        }
        if (chance < 0.5) 
        {
            1.5 => pShift[which].shift;
        }
        else
        {
            1.0 => pShift[which].shift;
        }
        
        // play shifted pitch, consider env when calculating duration
        // use period of silence?
        env[which].keyOn();
        (duration - rampTime - 0::ms) => now;
        
        env[which].keyOff();
        (rampTime + 0::ms) => now;
    }
}