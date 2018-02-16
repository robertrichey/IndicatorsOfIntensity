// TODO: summarize class

public class VoiceFragments {
    
    5 => int numVoices;
    int buffVoices[numVoices];
    
    SndBuf2 buff[numVoices];
    Envelope env[numVoices];
    NRev rev[numVoices];
    Pan2 pan[numVoices]; 
    Envelope masterEnv;
    Gain masterGain;
    
    0.32 => masterGain.gain;
    // Delay del[numVoices];
    
    1 => int isOff;
    
    string filename[23];
    
    for (0 => int i; i < filename.size(); i++) {
        <<< i >>>;
        "/voice/" + Std.itoa(i) + ".wav" => filename[i];
    }
    
    for (0 => int i; i < buff.size(); i++) {
        buff[i] => masterEnv => env[i] => rev[i] => masterGain => pan[i] => dac;
        //buff[i] => del[i] => del[i] => rev[i];
        //2000::ms => del[i].max;
        20::ms => env[i].duration;
        //Math.random2f(-0.9, 0.9) => pan[i].pan;
    }
    
    

    
    // Gradually turned down gain
    spork ~ turnDown();
    
    // now < later
    fun void turnOn(dur length) {
        // TODO: necessary?
        //Math.random2(5, 10)::second => dur length;
        
        for (0 => int i; i < numVoices; i++) {
            Math.random2f(-0.9, 0.9) => pan[i].pan;
        }
        spork ~ envelopeOn(length);
        
        now + length => time later;
        
        while (now < later) {
            spork ~ play();
            Math.random2(500, 1000)::ms => now;
        }
        1000::ms => now;
    }
    
    fun void envelopeOn(dur length) {
        length * 0.25 => masterEnv.duration;
        
        masterEnv.keyOn();
        length * 0.75 => now;
        masterEnv.keyOff();
        masterEnv.duration() => now;
    }
    
    fun void play() {
        getVoice2(buffVoices) => int which;
        int len;
        
        if (Math.randomf() > 0.6) {
            Math.random2f(0.3, 0.8) => rev[which].mix;
            Math.random2(200, 500) => len;
        }
        else {
            0 => rev[which].mix;
            Math.random2(1000, 2000) => len;
        }
        /*
        if (Math.randomf() > 1.7) {
            Math.random2f(0.1, 0.6) => del[which].gain;
            Math.random2f(50, 2000)::ms => del[which].delay;
        }
        else {
            0 => del[which].gain;
        }
        */
        me.dir() + filename[Math.random2(0, filename.size()-1)] => buff[which].read;
        Math.random2f(0.5, 1.2) => buff[which].gain;
        //20::ms => env[which].duration;
        //Math.random2f(-0.9, 0.9) => pan[which].pan;
        Math.random2(0, buff[which].samples()-1) => buff[which].pos;
        
        env[which].keyOn();
        len::ms => now;
        
        env[which].keyOff();
        env[which].duration() => now;
        
        0 => buffVoices[which]; 
    }
    
    fun int getVoice2(int voices[]) {    
        while (true) { 
            Math.random2(0, voices.size()-1) => int which;
            
            if (voices[which] == 0) {            
                1 => voices[which];
                return which;
            }
            5::ms => now;
        }
    }
    
    fun void turnDown() {
        9600 => int totalDuration;
        masterGain.gain() / totalDuration => float gainDecrement;

        
        for (0 => int i; i < totalDuration; i++) {
            masterGain.gain() - gainDecrement => masterGain.gain;
            100::ms => now;
        }
    }
    
    // TODO: remove?
    fun void turnOn(float ringTime, Event e) {
        //p => pan.pan;
        
        0 => isOff;
        //ringTime * 0.005::ms => env.duration;
        masterEnv.keyOn(); // DUR???        
        
        10::second => now;

        masterEnv.duration() => now;
        1 => isOff;
        
        e.signal();
    }
    
    /*
    960 / 4 => int x;
    
    1.0 => float threshold;
    0.0 => float minChance;
    threshold - minChance => float difference;
    
    <<< x / 1.618 >>>;
    Std.ftoi(x / 1.618) => int peakDensity;
    
    difference / peakDensity => float thresholdDecrement;
    difference / (x - peakDensity) => float thresholdIncrement;
    
    <<< difference / peakDensity >>>;
    <<< difference / (x - peakDensity) >>>;
    
    
    for (0 => int i; i < x; i++) {
        Math.randomf() => float chance;
        //1 => float chance;
        
        if (chance > threshold) {
            // play something
            spork ~ play();
        }
        if (i < peakDensity) {
            thresholdDecrement -=> threshold;
        }
        else {
            thresholdIncrement +=> threshold;
        }
        4::second => now;
    }
    5::second => now;
    */
}