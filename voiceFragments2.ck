/**
 * A class that plays fragments of speech samples
 *
 * Samples are effected with three comb filters
 * Samples gradually fade in, reaching peak at golden section before fading out
 */

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
    960000 => int totalDuration;

    1 => int isOff;
    
    // Create array and load samples
    string filename[23];
    
    for (0 => int i; i < filename.size(); i++) {
        "/voice_sounds/" + Std.itoa(i) + ".wav" => filename[i];
    }
        
    // Sound chain, set envelope, buff gain
    for (0 => int i; i < numVoices; i++) {
        buff[i] => masterEnv => dryGain[i] => env[i] => masterGain => pan[i] => dac;//pan[i] => dac;
        
        masterEnv => combGain[i];
        
        combGain[i] => delay1[i] => env[i];
        combGain[i] => delay2[i] => env[i];
        combGain[i] => delay3[i] => env[i];
        
        delay1[i] => delay1Gain[i] => delay1[i];
        delay2[i] => delay2Gain[i] => delay2[i];
        delay3[i] => delay3Gain[i] => delay3[i];
        
        500::ms => env[i].duration;
    }
    
    // Gradually turn up gain
    spork ~ shiftGain(); 
    
    /**
     * Gradually increases gain until maxGain is achieved at golden section,
     * then decreases gain to 0 over remainder of totalDuration
     */
    fun void shiftGain() {
        // TODO: pass in from outside class. Needs to be synchronized with rest of piece
        totalDuration / 100 => int dividedDur;
        Std.ftoi(dividedDur * 0.618) => int longSection;
        dividedDur - longSection => int shortSection;
        
        // max was previously 0.16
        0.12 => float maxGain;
        maxGain / longSection => float gainIncrement;
        
        // Increase gain      
        for (0 => int i; i < longSection; i++) {
            masterGain.gain() + gainIncrement => masterGain.gain;
            100::ms => now;
        }
        
        masterGain.gain() / shortSection => float gainDecrement;
        
        // Decrease gain
        for (0 => int i; i < shortSection; i++) {
            masterGain.gain() - gainDecrement => masterGain.gain;
            100::ms => now;
        }
    }
    
    /**
     * Play voice fragments for a given duration
     */    
    fun void turnOn(dur length) {
        setPan();
        spork ~ envelopeOn(length);
        
        now + length => time later;
        
        while (now < later) {
            spork ~ play();
            Math.random2(1000, 2500)::ms => now;
        }
        5000::ms => now;
    }
    
    /**
     * Randomly set each Pan2 object
     */
    fun void setPan() {
        for (0 => int i; i < numVoices; i++) {
            Math.random2f(-0.3, 0.3) => pan[i].pan;
        }        
    }
    
    /**
     * Collectively fade voice fragments in and out using a master envelope
     */    
    fun void envelopeOn(dur length) {
        length * 0.2 => masterEnv.duration;
        
        masterEnv.keyOn();
        length * 0.8 => now;
        masterEnv.keyOff();
        masterEnv.duration() => now;
    }
    
    /**
     * Set fragment parameters and play
     */   
    fun void play() {
        getVoice(buffVoices) => int which;

        if (which > -1) {
            // Set comb filter parameters
            setComb(which);
            
            // Set buffer parameters
            me.dir() + filename[Math.random2(0, filename.size()-1)] => buff[which].read;
            Math.random2(0, buff[which].samples()) => buff[which].pos;
            
            // Set duration and play
            Math.random2(2000, 5000) => int fragLength;
            
            env[which].keyOn();
            fragLength::ms => now;
            
            env[which].keyOff();
            env[which].duration() => now;
            
            0 => buffVoices[which]; 
        }
    }
    
    /**
     * Set comb filters and gain parameters based on chance
     */
    fun void setComb(int which) {
        // Set gains
        Math.random2f(0.3, 0.5) => dryGain[which].gain;
        Math.random2f(0.6, 0.75) => combGain[which].gain;
        Math.random2f(0.85, 0.97) => 
        delay1[which].gain => delay2[which].gain => delay3[which].gain;
        
        // Select values for comb delays
        // TODO: check filter sounds for different ranges of x
        Math.random2f(1, 12) => float x;
        Math.random2(1, 12) => int y;
        Math.random2(1, 12) => int z;
        
        // Set delays based on value of x
        x::ms => delay1[which].delay;
        raiseByHalfSteps(x, y)::ms => delay2[which].delay;
        raiseByHalfSteps(x, z)::ms => delay3[which].delay;
    }
    
    /**
     * Select next available voice from voices[]
     */ 
    fun int getVoice(int voices[]) {    
        for (0 => int i; i < voices.size(); i++) { 
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