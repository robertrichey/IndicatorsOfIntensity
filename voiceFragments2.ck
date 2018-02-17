
public class VoiceFragments2 {
    8 => int numVoices;
    int buffVoices[numVoices];
    
    SndBuf2 buff[numVoices];
    Envelope env[numVoices];
    Pan2 pan[numVoices]; 
    
    Gain combGain[numVoices];
    Gain dryGain[numVoices];
    Gain delay1Gain[numVoices];
    Gain delay2Gain[numVoices];
    Gain delay3Gain[numVoices];
    
    DelayL delay1[numVoices];
    DelayL delay2[numVoices];
    DelayL delay3[numVoices];
    
    
    // Sound chain
    for (0 => int i; i < numVoices; i++) {
        // TODO: Use pan?
        buff[i] => dryGain[i] => env[i] => dac;//pan[i] => dac;
        
        buff[i] => combGain[i];
        
        combGain[i] => delay1[i] => env[i];
        combGain[i] => delay2[i] => env[i];
        combGain[i] => delay3[i] => env[i];
        
        delay1[i] => delay1Gain[i] => delay1[i];
        delay2[i] => delay2Gain[i] => delay2[i];
        delay3[i] => delay3Gain[i] => delay3[i];
        
        1000::ms => env[i].duration;
    }
    
    
    // Create array and load samples
    string filename[23];
    
    for (0 => int i; i < filename.size(); i++) {
        "/voice/" + Std.itoa(i) + ".wav" => filename[i];
    }
    
    
    while (true) {
        spork ~ play();
        Math.random2(1000, 2500)::ms => now;
    }
    
    fun void play() {
        getVoice(buffVoices) => int which;
        
        if (which > -1) {
            if (Math.randomf() > 0.0) { 
                turnOnComb(which);
            }
            else {
                0 => combGain[which].gain;
                Math.random2f(0.5, 0.9) => dryGain[which].gain;
                
            }
            
            me.dir() + filename[Math.random2(0, filename.size()-1)] => buff[which].read;
            //Math.random2f(-0.8, 0.8) => pan[which].pan;
            
            Math.random2(2000, 5000) => int len;
            Math.random2(0, buff[which].samples()) => buff[which].pos;
            
            env[which].keyOn();
            len::ms => now;
            
            env[which].keyOff();
            env[which].duration() => now;
            
            0 => buffVoices[which]; 
        }
    }
    
    fun void turnOnComb(int which) {
        Math.random2f(0.2, 0.6) => dryGain[which].gain;
        Math.random2f(0.3, 0.6) => combGain[which].gain;
        Math.random2f(0.80, 0.97) => 
        delay1[which].gain => delay2[which].gain => delay3[which].gain;
        
        Math.random2f(1, 12) => float x;
        Math.random2(1, 12) => int y;
        Math.random2(1, 12) => int z;
        
        x::ms => delay1[which].delay;
        raiseByHalfSteps(x, y)::ms => delay2[which].delay;
        raiseByHalfSteps(x, z)::ms => delay3[which].delay;
    }
    
    fun int getVoice(int voices[]) {
        for (int i; i < voices.size(); i++) { 
            if (voices[i] == 0) {            
                1 => voices[i];
                return i;
            }
        }
        return -1;
    }
    
    /**
    * Raises a float x by y equally tempered half steps
    */
    fun float raiseByHalfSteps(float x, float y) {
        return x * Math.pow(Math.pow(2, 1/12.0), y);
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