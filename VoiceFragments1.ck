/**
 * A class that plays fragments of speech samples
 *
 * Samples are occasionally played back in shorter duration with reverb added
 * Samples gradually fade out over the duration of the piece
 */ 

public class VoiceFragments {
    
    5 => int numVoices;
    int buffVoices[numVoices];
    
    SndBuf2 buff[numVoices];
    Envelope env[numVoices];
    NRev rev[numVoices];
    Pan2 pan[numVoices]; 
    Envelope masterEnv;
    Gain masterGain;
    
    0.27 => masterGain.gain;
    1 => int isOff;
    string filename[23];
    
    for (0 => int i; i < filename.size(); i++) {
        "/voice_sounds/" + Std.itoa(i) + ".wav" => filename[i];
    }
    
    // Sound chain, set envelope
    for (0 => int i; i < buff.size(); i++) {
        buff[i] => masterEnv => env[i] => rev[i] => masterGain => pan[i] => dac;
        //20::ms => env[i].duration;
        Math.random2f(-0.9, 0.9) => pan[i].pan;
    }
    
       
    // Gradually turn down gain
    spork ~ turnDown();
    
    /**
     * Play voice fragments for a given duration
     */    
    fun void turnOn(dur length) {
        setPan();
        spork ~ envelopeOn(length);
        
        now + length => time later;
        
        while (now < later) {
            spork ~ play();
            Math.random2(500, 1200)::ms => now;
        }
        // Allow sporked shreds to terminate. 
        // NOTE: duration must consider max possible fragLength in play function
        2000::ms => now;
    }
    
    /**
     * Randomly set each Pan2 object
     */
    fun void setPan() {
        for (0 => int i; i < numVoices; i++) {
            Math.random2f(-0.9, 0.9) => pan[i].pan;
        }        
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
    
    /**
     * Set fragment parameters and play
     */     
    fun void play() {
        getVoice(buffVoices) => int which;        
        int fragLength;
        
        // Set duration and reverb based on chance
        if (Math.randomf() > 0.6) {
            Math.random2f(0.3, 0.8) => rev[which].mix;
            Math.random2(200, 500) => fragLength;
        }
        else {
            0 => rev[which].mix;
            Math.random2(1000, 2000) => fragLength;
        }
        
        // Set buffer parameters
        me.dir() + filename[Math.random2(0, filename.size()-1)] => buff[which].read;
        Math.random2f(0.5, 1.2) => buff[which].gain;
        Math.random2(0, buff[which].samples()-1) => buff[which].pos;
        
        // Turn on envelope for selected buffer
        env[which].keyOn();
        fragLength::ms => now;
        
        env[which].keyOff();
        env[which].duration() => now;
        
        0 => buffVoices[which]; 
    }

    /**
     * Select a voice at random from voices[]
     */     
    fun int getVoice(int voices[]) {    
        while (true) { 
            Math.random2(0, voices.size()-1) => int which;
            
            if (voices[which] == 0) {            
                1 => voices[which];
                return which;
            }
            5::ms => now;
        }
    }

    /**
     * Gradually decrease gain to zero over the duration of the piece
     */     
    fun void turnDown() {
        // TODO: pass in from outside class. Needs to be synchronized with rest of piece
        9600 => int totalDuration;
        masterGain.gain() / totalDuration => float gainDecrement;
        
        for (0 => int i; i < totalDuration; i++) {
            masterGain.gain() - gainDecrement => masterGain.gain;
            100::ms => now;
        }
    }
}