// TODO: summarize class

public class ShiftingFMWave {
    SampleGrains grains;
    float totalDuration;
    1 => int isOff;
    
    spork ~ panShift();
    
    // PATCH
    SinOsc modulator => TriOsc carrier => Envelope env => Pan2 pan => dac;

    // Tell the oscillator to interpret input as frequency modulation
    2 => carrier.sync;
    
    /**
     * Sets a waveform into a state where it can be turned on and off
     */
    fun void play() {
        // implement in subclass
    }
    
    /**
     * Triggers the waveform to be audible by keying on the envelope 
     * and sending an event signal after ringTime has concluded
     */
    fun void turnOn(float ringTime, float p, Event e) {
        p => pan.pan;
        
        float rampUp;
        float rampDown;
        
        Math.randomf() => float chance;
            
        if (chance > 0.66) {
            Math.random2f(0.25, 0.75) => rampUp;
            1 - rampUp => rampDown; 
        }
        else if (chance > 0.33) {
            0.95 => rampUp;
            0.05 => rampDown;
        }
        else {
            0.005 => rampUp;
            0.995 => rampDown;
        }
        
        Math.random2f(0.7, 1.3) => float multiplier;
        
        0 => isOff;
        ringTime * multiplier * rampUp::ms => env.duration;
        env.keyOn();
        env.duration() => now;

        ringTime * multiplier * rampDown::ms => env.duration;
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
    
    /**
     * Gradually shifts the frequency of an oscillator over a given duration 
     */
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
    
    /**
     * Gradually shifts the gain of an oscillator over a given duration 
     */
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
    
    /**
     * Gradually shifts the frequency of an oscillator over a given duration 
     */
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
    
    /**
     * Gradually shifts the gain of an oscillator over a given duration 
     */
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
        while (pan.pan() > -0.9) {
            pan.pan() - 0.005 => pan.pan;
            15::ms => now;
            //<<< pan.pan() >>>;
        }
    }
    
    /**
     * Gradually pan right
     */
    fun void panRight() {
        while (pan.pan() < 0.9) {
            pan.pan() + 0.005 => pan.pan;
            15::ms => now;
            //<<< pan.pan() >>>;
        }
    }
    
    /**
     * Return current pan setting
     */
    fun float getPan() {
        return pan.pan();
    }
}