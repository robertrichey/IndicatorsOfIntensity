
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
    
    Envelope masterEnv;
    Gain masterGain;
    
    0.0 => masterGain.gain;
    1 => int isOff;
    
    // Create array and load samples
    string filename[23];
    
    for (0 => int i; i < filename.size(); i++) {
        "/voice/" + Std.itoa(i) + ".wav" => filename[i];
    }
        
    // Sound chain, set envelope, buff gain
    for (0 => int i; i < numVoices; i++) {
        // TODO: Use pan?
        buff[i] => masterEnv => dryGain[i] => env[i] => masterGain => dac;//pan[i] => dac;
        
        masterEnv => combGain[i];
        
        combGain[i] => delay1[i] => env[i];
        combGain[i] => delay2[i] => env[i];
        combGain[i] => delay3[i] => env[i];
        
        delay1[i] => delay1Gain[i] => delay1[i];
        delay2[i] => delay2Gain[i] => delay2[i];
        delay3[i] => delay3Gain[i] => delay3[i];
        
        0.1 => buff[i].gain;
        1000::ms => env[i].duration;
    }
    
    // Gradually turn up gain
    spork ~ shiftGain(); 
    
    fun void shiftGain() {
        // TODO: pass in from top of the file? Needs to be synchronized with rest of piece
        3000 => int totalDuration;
        Std.ftoi(totalDuration * 0.618) => int longSection;
        totalDuration - longSection => int shortSection;
        
        0.01 => float maxGain;
        maxGain / (longSection / 100)  => float gainIncrement;
                
        for (0 => int i; i < longSection; i++) {
            masterGain.gain() + gainIncrement => masterGain.gain;
            100::ms => now;
        }
        
        masterGain.gain() / shortSection => float gainDecrement;
        
        for (0 => int i; i < shortSection; i++) {
            masterGain.gain() - gainDecrement => masterGain.gain;
            100::ms => now;
        }
    }
    
    /**
     * Play voice fragments for a given duration
     */    
    fun void turnOn(dur length) {
        spork ~ envelopeOn(length);
        
        now + length => time later;
        <<< "VoiceFragment2 gain: ", masterGain.gain() >>>;
        
        while (now < later) {
            spork ~ play();
            Math.random2(1000, 2500)::ms => now;
        }
        1000::ms => now;
    }
    
    /**
     * Collectively fade voice fragments in and out using a master envelope
     */    
    fun void envelopeOn(dur length) {
        length * 0.25 => masterEnv.duration;
        
        masterEnv.keyOn();
        length * 0.75 => now;
        masterEnv.keyOff();
        masterEnv.duration() => now;
    }
    
    fun void play() {
        getVoice(buffVoices) => int which;
        
        if (which > -1) {
            // Decide comb filter parameters
            if (Math.randomf() > 0.0) { 
                turnOnComb(which);
            }
            else {
                0 => combGain[which].gain;
                Math.random2f(0.25, 0.45) => dryGain[which].gain;
            }
            
            // Set buffer parameters
            me.dir() + filename[Math.random2(0, filename.size()-1)] => buff[which].read;
            Math.random2(0, buff[which].samples()) => buff[which].pos;
            //Math.random2f(-0.8, 0.8) => pan[which].pan;
            
            // Set duration and play
            Math.random2(2000, 5000) => int fragLength;
            
            env[which].keyOn();
            fragLength::ms => now;
            
            env[which].keyOff();
            env[which].duration() => now;
            
            0 => buffVoices[which]; 
        }
    }
    
    fun void turnOnComb(int which) {
        Math.random2f(0.1, 0.3) => dryGain[which].gain;
        Math.random2f(0.15, 0.3) => combGain[which].gain;
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
}