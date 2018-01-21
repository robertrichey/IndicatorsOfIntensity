public class ShiftingFMWave {
    SampleGrains grains;
    float totalDuration;
    1 => int isOff;
    
    spork ~ panShift();
    
    // PATCH
    SinOsc modulator => TriOsc carrier => Envelope env => Pan2 pan => dac;
    
    // Tell the oscillator to interpret input as frequency modulation
    2 => carrier.sync;
        
    fun void play() {
        totalDuration / grains.numberOfGrains => float shiftDur;
        
        // Play sound based on grain for total duration
        for (0 => int i; i < grains.numberOfGrains - 1; i++) {
            
            Std.mtof(getTransformation(grains.minPower, grains.maxPower, 36, 94, grains.power[i])) => 
            float startCarFreq;
            
            Std.mtof(getTransformation(grains.minPower, grains.maxPower, 36, 94, grains.power[i + 1])) => 
            float endCarFreq;
            
            
            getTransformation(grains.minSpeed, grains.maxSpeed, 0, 500, grains.speed[i]) => 
            float startModFreq;
            
            getTransformation(grains.minSpeed, grains.maxSpeed, 0, 500, grains.speed[i + 1]) => 
            float endModFreq;
            
            
            getTransformation(grains.minCadence, grains.maxCadence, 0.08, 0.15, grains.cadence[i]) => 
            float startCarGain;
            
            getTransformation(grains.minCadence, grains.maxCadence, 0.08, 0.15, grains.cadence[i + 1]) => 
            float endCarGain;
            
            
            getTransformation(grains.minHeartRate, grains.maxHeartRate, 0, 10000, grains.heartRate[i]) => 
            float startModGain;
            
            getTransformation(grains.minHeartRate, grains.maxHeartRate, 0, 10000, grains.heartRate[i + 1]) => 
            float endModGain;
            
            spork ~ shiftCarPitch(startCarFreq, endCarFreq, shiftDur);
            spork ~ shiftCarGain(startCarGain, endCarGain, shiftDur);
            spork ~ shiftModPitch(startModFreq, endModFreq, shiftDur);
            spork ~ shiftModGain(startModGain, endModGain, shiftDur);

            shiftDur::ms => now;
        }
    }
    <<< "Done" >>>;
    
    // TODO: document, use isOn bool function
    fun void turnOn(float ringTime, float p, Event e) {
        p => pan.pan;

        0 => isOff;
        ringTime * 0.005::ms => env.duration;
        env.keyOn();
        env.duration() => now;

        ringTime * 0.995::ms => env.duration;
        env.keyOff();

        env.duration() => now;
        1 => isOff;
        
        e.signal();
    }
    
    /** 
    * Linear transformation:
    * For a given value between [a, b], return corresponding value between [c, d]
    * source: https://stackoverflow.com/questions/345187/math-mapping-numbers
    */
    fun float getTransformation(float a, float b, float c, float d, float x) {
        return (x - a) / (b - a) * (d - c) + c;
    }
    
    fun void shiftCarPitch(float start, float finish, float duration) {
        finish - start => float diff;
        diff / duration => float grain;
        start => float current => carrier.freq;
        
        for (0 => int i; i < duration; i++) {
            grain +=> current;
            current => carrier.freq;
            1::ms => now;
        }
        finish => carrier.freq;
    }
    
    fun void shiftCarGain(float start, float finish, float duration) {
        finish - start => float diff;
        diff / duration => float grain;
        start => float current => carrier.gain;
        
        for (0 => int i; i < duration; i++) {
            grain +=> current;
            current => carrier.gain;
            1::ms => now;
        }
        finish => carrier.gain;
    }
    
    fun void shiftModPitch(float start, float finish, float duration) {
        finish - start => float diff;
        diff / duration => float grain;
        start => float current => modulator.freq;
        
        for (0 => int i; i < duration; i++) {
            grain +=> current;
            current => modulator.freq;
            1::ms => now;
        }
        finish => modulator.freq;
    }
    
    fun void shiftModGain(float start, float finish, float duration) {
        finish - start => float diff;
        diff / duration => float grain;
        start => float current => modulator.gain;
        
        for (0 => int i; i < duration; i++) {
            grain +=> current;
            current => modulator.gain;
            1::ms => now;
        }
        finish => modulator.gain;
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
        while (pan.pan() > -0.9) {
            pan.pan() - 0.005 => pan.pan;
            15::ms => now;
            //<<< pan.pan() >>>;
        }
    }
    
    fun void panRight() {
        while (pan.pan() < 0.9) {
            pan.pan() + 0.005 => pan.pan;
            15::ms => now;
            //<<< pan.pan() >>>;
        }
    }
}