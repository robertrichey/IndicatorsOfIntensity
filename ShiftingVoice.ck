/**
 * Plays voice recordings with a comb filters whose values change based current cycling parameters
 */

public class ShiftingVoice {
    // our patch - feed1Gainforward part
    SndBuf2 buff => Gain dryGain => Envelope envMain => Gain master => Envelope envFrag => Pan2 pan => dac;
    
    buff => Gain combGain;
    
    combGain => DelayL d1 => envMain;
    combGain => DelayL d2 => envMain;
    combGain => DelayL d3 => envMain;
        
    // feedback
    d1 => Gain d1Gain => d1;
    d2 => Gain d2Gain => d2;
    d3 => Gain d3Gain => d3;
  
    
    // Load voice samples into array
    string filename[23];
    
    for (0 => int i; i < filename.size(); i++) {
        <<< i >>>;
        "/voice/" + Std.itoa(i) + ".wav" => filename[i];
    }
    
    // TODO: remove and access from one place
    RideData data;
    data.getGrains(8) @=> SampleGrains grains;
    
    
    // TODO: remove and access from one place
    960000 => float totalDuration;
        
        
    // Set two delay lines to be a perfect fourth apart and the third assigned a random interval
    2 => float d1Delay;
    7 => float d2Delay;
    Math.random2(1, 12) => float d3Delay;
    
    // Set gain parameters
    0.0 => master.gain;
    0.75 => combGain.gain;
    0.5 => dryGain.gain;
    0.95 => d1Gain.gain => d2Gain.gain => d3Gain.gain;
    
    
    // spork supporting functions
    spork ~ shiftGainUp();
    spork ~ shift();
    spork ~ panShift();
    // spork ~ fragmentVoice();
    
    // Bool for detecting whether a sound file is currently playing
    1 => int isOff;
    
    // TODO: remove if unused
    envFrag.keyOn();
    
    /**
     * Select a voice recording for playback and return its length
     */
    fun dur setVoice() {
        me.dir() + filename[Math.random2(0, filename.size()-1)] => buff.read;
        return buff.length();
    }
    
    /**
     * Turns on envelope and plays selected sound file
     */
    fun void play() {
        0 => isOff;
        
        // Set parameters        
        Math.random2f(-1.0, 1.0) => pan.pan; // TODO: Necessary when panShift is always running in background? 
        
        Math.random2(1, 12) => d3Delay;
        
        // TODO: Necessary when shift is always running in background? 
        d1Delay::ms => d1.delay;
        raiseByHalfSteps(d1Delay, d2Delay)::ms => d2.delay;
        raiseByHalfSteps(d1Delay, d3Delay)::ms => d3.delay;
        
        3000::ms => envMain.duration;
        
        // Make sound by keying envelope on and off
        envMain.keyOn();
        
        buff.length() - envMain.duration() => now;
        2000::ms => now;
        envMain.keyOff();
        envMain.duration() => now;
        
        1 => isOff;
    }
    
    /**
     * Gradually increases gain over totalDuration
     */
    fun void shiftGainUp() {
        1.4 => float maxGain;
        maxGain / (totalDuration / 100)  => float gainIncrement;
        
        while (master.gain() < maxGain) {
            gainIncrement + master.gain() => master.gain;
            //<<< "SVG ", master.gain() >>>;
            100::ms => now;
        }
    }
    
    /**
     * Continually pans wave back and forth across stereo field
     */
    fun void panShift() {
        while (true) {
            if (pan.pan() > 0) {
                panLeft();
            }
            else {
                panRight();
            }
        }
    }

    /**
     * Gradually pan left
     */    
    fun void panLeft() {
        while (pan.pan() > -0.95) {
            pan.pan() - 0.005 => pan.pan;
            15::ms => now;
            //<<< pan.pan() >>>;
        }
    }

    /**
     * Gradually pan right
     */    
    fun void panRight() {
        while (pan.pan() < 0.95) {
            pan.pan() + 0.005 => pan.pan;
            15::ms => now;
        }
    }
    
    /**
     * Shifts the duration of delay lines based on current power output in an array of grains
     */
     fun void shift() {
         totalDuration / grains.numberOfGrains => float shiftDur;

         // Play sound based on grain for total duration
         for (0 => int i; i < grains.numberOfGrains - 1; i++) {  
             if (!isOff) {     
                 Std.mtof(getTransformation(grains.minPower, grains.maxPower, 3, 10, grains.power[i])) => 
                 float startDelay;
                 
                 Std.mtof(getTransformation(grains.minPower, grains.maxPower, 3, 10, grains.power[i + 1])) => 
                 float endDelay;
                 
                 spork ~ shiftDelay(startDelay, endDelay, shiftDur);
             }
             shiftDur::ms => now;
         }
     }
    
    /**
     * Shifts delay lines in sync with one another over a given duration. 
     * start and finish represent the delay duration of d1
     */
    fun void shiftDelay(float start, float finish, float duration) {
        finish - start => float diff;
        diff / duration => float grain;
        start => float current;
        
        // Ensure parameters begin at start
        current::ms => d1.delay;
        raiseByHalfSteps(current, d2Delay)::ms => d2.delay;
        raiseByHalfSteps(current, d3Delay)::ms => d3.delay;
        
        // Gradually shift delay lines
        for (0 => int i; i < duration; i++) {
            grain +=> current;
            
            current::ms => d1.delay;
            raiseByHalfSteps(current, d2Delay)::ms => d2.delay;
            raiseByHalfSteps(current, d3Delay)::ms => d3.delay;
            
            1::ms => now;
        }
        
        // Ensure parameters end at finish
        finish::ms => d1.delay;
        raiseByHalfSteps(current, d2Delay)::ms => d2.delay;
        raiseByHalfSteps(current, d3Delay)::ms => d3.delay;
    } 
    
    // TODO: move to an area where it can be accessed by all necessary classes?
    fun float getTransformation(float a, float b, float c, float d, float x) {
        return (x - a) / (b - a) * (d - c) + c;
    }
    
    // TODO: remove?
    fun void fragmentVoice() {
        20::ms => envFrag.duration;
        
        while (true) {
            Math.random2(500, 800)::ms => now;
            
            envFrag.keyOn();
            Math.random2(100, 1000)::ms => now;
            envFrag.keyOff();
        }
    }
    
    /**
     * Raises a float x by y equally tempered half steps
     */
    fun float raiseByHalfSteps(float x, float y) {
        return x * Math.pow(Math.pow(2, 1/12.0), y);
    }
}