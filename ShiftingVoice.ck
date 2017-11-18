public class ShiftingVoice {
    // our patch - feedforward part
    SndBuf buff => Gain g => DelayL d => Envelope env => Pan2 pan;
    g => DelayL d2 => env => pan;
    g => DelayL d3 => env => pan;
    
    buff => Gain g2 => env => pan;
    pan => dac;
    
    // feedback
    d => Gain g3 => d;
    d2 => Gain g4 => d2;
    d3 => Gain g5 => d3;
    
    string filename[5];
    
    for (0 => int i; i < filename.size(); i++) {
        <<< i >>>;
        "/recordings/" + Std.itoa(i) + ".wav" => filename[i];
    }
    
    RideData data;
    data.getGrains(20) @=> SampleGrains oscGrains;
    
    900000 => float totalDuration;
    totalDuration / oscGrains.numberOfGrains => float shiftDur;
    
    
    // set parameters
    2 => float x;
    Math.random2(1, 12) => int y;
    Math.random2(1, 12) => int z;
    
    0.4 => g.gain;
    0.5 => g2.gain;
    0.96 => g3.gain => g4.gain => g5.gain;
    
    spork ~ shift();
    spork ~ panShift();
    
    1 => int isOff;
    
    fun void play() {
        0 => isOff;
        
        Math.random2f(-1.0, 1.0) => pan.pan;
        <<< pan.pan(), "pan" >>>;
        me.dir() + filename[Math.random2(0, filename.size()-1)] => buff.read;
        
        // set parameters
        2 => float x;
        Math.random2(1, 12) => y;
        Math.random2(1, 12) => z;
        
        x::ms => d.delay;
        raiseByHalfSteps(x, y)::ms => d2.delay;
        raiseByHalfSteps(x, z)::ms => d3.delay;
        
        buff.length() * 0.25 => env.duration;
        env.keyOn();
        
        buff.length() - env.duration() => now;
        3000::ms => now;
        env.keyOff();
        env.duration() => now;
        
        1 => isOff;
        //0 => buff.pos;
        //Math.random2f(1, 12) => x;
        //<<< x >>>;
    }
    
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
    
    fun void panLeft() {
        while (pan.pan() > -0.95) {
            pan.pan() - 0.005 => pan.pan;
            15::ms => now;
            //<<< pan.pan() >>>;
        }
    }
    
    fun void panRight() {
        while (pan.pan() < 0.95) {
            pan.pan() + 0.005 => pan.pan;
            15::ms => now;
            //<<< pan.pan() >>>;
        }
    }
    
    fun void shift() {
        // Play sound based on grain for total duration
        for (0 => int i; i < oscGrains.numberOfGrains - 1; i++) {       
            Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 3, 12, oscGrains.power[i])) => 
            float startDelay;
            
            Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 3, 12, oscGrains.power[i + 1])) => 
            float endDelay;
            
            spork ~ shiftDelay(startDelay, endDelay, shiftDur);
            
            shiftDur::ms => now;
        }
    }
    
    fun float getTransformation(float a, float b, float c, float d, float x) {
        return (x - a) / (b - a) * (d - c) + c;
    }
    
    fun void shiftDelay(float start, float finish, float duration) {
        finish - start => float diff;
        diff / duration => float grain;
        start => float current;
        // set parameters
        current::ms => d.delay;
        raiseByHalfSteps(current, y)::ms => d2.delay;
        raiseByHalfSteps(current, z)::ms => d3.delay;
        
        for (0 => int i; i < duration; i++) {
            grain +=> current;
            
            // set parameters
            current::ms => d.delay;
            raiseByHalfSteps(current, y)::ms => d2.delay;
            raiseByHalfSteps(current, z)::ms => d3.delay;
            
            1::ms => now;
        }
        finish::ms => d.delay;
        
        // set parameters
        finish::ms => d.delay;
        raiseByHalfSteps(current, y)::ms => d2.delay;
        raiseByHalfSteps(current, z)::ms => d3.delay;
    } 
    
    /**
    * Raises a float x by y equally tempered half steps
    */
    fun float raiseByHalfSteps(float x, float y) {
        return x * Math.pow(Math.pow(2, 1/12.0), y);
    }
}