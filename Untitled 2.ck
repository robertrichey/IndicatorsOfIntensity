SndBuf buffer;
Multicomb combs[3];
ResonZ filters[3];

//filters[0] => 
buffer => combs[0] => filters[0] => dac;
buffer => combs[1] => filters[1] => dac;
buffer => combs[2] => filters[2] => dac;

"/recordings/Record_" + Std.itoa(5) + ".wav" => string filepath;
me.dir() + filepath => buffer.read;

1000 => int revTime; 
revTime::ms => combs[0].revtime;
revTime::ms => combs[1].revtime;
revTime::ms => combs[2].revtime;


while (true) {
    //Math.random2f(50,60) => float x;
    80 => float x;

    x => float freq1;
    combs[0].set(freq1, freq1);
    freq1 => filters[0].freq;
    
    x * 1.5 => float freq2;
    combs[1].set(freq2, freq2);
    freq2 => filters[1].freq;

    
    x * 12/11 => float freq3;
    combs[1].set(freq2, freq2);
    freq3 => filters[2].freq;
    
    1.0 => filters[0].Q => filters[1].Q => filters[2].Q;

    1::minute => now;
}