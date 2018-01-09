public class ShiftingVoice {
    // our patch - feed1Gainforward part
    SndBuf2 buff => Gain dryGain => Envelope envMain => Envelope envFrag => Pan2 pan => dac;
    
    buff => Gain combGain;
    
    combGain => DelayL d1 => envMain;
    combGain => DelayL d2 => envMain;
    combGain => DelayL d3 => envMain;
        
    // feedback
    d1 => Gain d1Gain => d1;
    d2 => Gain d2Gain => d2;
    d3 => Gain d3Gain => d3;
    
    // TODO: necessary?
    0.99 => buff.rate;
    
    // Load voice samples into array
    string filename[23];
    
    for (0 => int i; i < filename.size(); i++) {
        <<< i >>>;
        "/voice/" + Std.itoa(i) + ".wav" => filename[i];
    }
    
    RideData data;
    data.getGrains(8) @=> SampleGrains oscGrains;
    
    960000 => float totalDuration;
    totalDuration / oscGrains.numberOfGrains => float shiftDur;
    
    
    // set parameters
    2 => float x;
    Math.random2(1, 12) => int y;
    Math.random2(1, 12) => int z;
    
    0.75 => combGain.gain;
    0.5 => dryGain.gain;
    0.95 => d1Gain.gain => d2Gain.gain => d3Gain.gain;
    
    spork ~ shift();
    spork ~ panShift();
    spork ~ fragmentVoice();
    
    1 => int isOff;
    
    fun void play() {
        0 => isOff;
        
        Math.random2f(-1.0, 1.0) => pan.pan;
        // <<< pan.pan(), "pan" >>>;
        me.dir() + filename[Math.random2(0, filename.size()-1)] => buff.read;
        
        // set parameters
        2 => float x;
        7 => y;
        Math.random2(1, 12) => z;
        
        x::ms => d1.delay;
        raiseByHalfSteps(x, y)::ms => d2.delay;
        raiseByHalfSteps(x, z)::ms => d3.delay;
        
        //buff.length() * 0.25 => envMain.duration;
        3000::ms => envMain.duration;
        envMain.keyOn();
        
        buff.length() - envMain.duration() => now;
        2000::ms => now;
        envMain.keyOff();
        envMain.duration() => now;
        
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
            Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 3, 10, oscGrains.power[i])) => 
            float startDelay;
            
            Std.mtof(getTransformation(oscGrains.minPower, oscGrains.maxPower, 3, 10, oscGrains.power[i + 1])) => 
            float endDelay;
            
            spork ~ shiftDelay(startDelay, endDelay, shiftDur);
            
            shiftDur::ms => now;
        }
    }
    
    fun void fragmentVoice() {
        20::ms => envFrag.duration;
        
        while (true) {
            Math.random2(500, 800)::ms => now;
            
            envFrag.keyOn();
            Math.random2(100, 1000)::ms => now;
            envFrag.keyOff();
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
        current::ms => d1.delay;
        raiseByHalfSteps(current, y)::ms => d2.delay;
        raiseByHalfSteps(current, z)::ms => d3.delay;
        
        for (0 => int i; i < duration; i++) {
            grain +=> current;
            
            // set parameters
            current::ms => d1.delay;
            raiseByHalfSteps(current, y)::ms => d2.delay;
            raiseByHalfSteps(current, z)::ms => d3.delay;
            
            1::ms => now;
        }
        finish::ms => d1.delay;
        
        // set parameters
        finish::ms => d1.delay;
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