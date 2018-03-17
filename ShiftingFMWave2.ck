// TODO: summarize class

public class ShiftingFMWave2 extends ShiftingFMWave {
    [0.08, 0.18] @=> baseGains;

    /**
     * Use cycling data to transform an FM wave over totalDuration milliseconds
     */
    fun void play() {
        totalDuration / grains.numberOfGrains => float shiftDur;
        getGain() @=> curGains;

        // Play sound based on grain for total duration
        for (0 => int i; i < grains.numberOfGrains - 1; i++) {
            Std.mtof(getTransformation(grains.minCadence, grains.maxCadence, 24, 48, grains.cadence[i])) => 
            float startCarFreq;
            
            Std.mtof(getTransformation(grains.minCadence, grains.maxCadence, 24, 48, grains.cadence[i + 1])) => 
            float endCarFreq;
            
            
            getTransformation(grains.minPower, grains.maxPower, 10, 100, grains.power[i]) => 
            float startModFreq;
            
            getTransformation(grains.minPower, grains.maxPower, 10, 100, grains.power[i + 1]) => 
            float endModFreq;
            
            
            getTransformation(grains.minCadence, grains.maxCadence, curGains[0], curGains[1], grains.cadence[i]) => 
            float startCarGain;
            
            getTransformation(grains.minCadence, grains.maxCadence, curGains[0], curGains[1], grains.cadence[i + 1]) => 
            float endCarGain;
            
            
            getTransformation(grains.minSpeed, grains.maxSpeed, 500, 2000, grains.speed[i]) => 
            float startModGain;
            
            getTransformation(grains.minSpeed, grains.maxSpeed, 500, 2000, grains.speed[i + 1]) => 
            float endModGain;
            
            spork ~ shiftCarPitch(startCarFreq, endCarFreq, shiftDur);
            spork ~ shiftCarGain(startCarGain, endCarGain, shiftDur);
            spork ~ shiftModPitch(startModFreq, endModFreq, shiftDur);
            spork ~ shiftModGain(startModGain, endModGain, shiftDur);
            shiftDur::ms => now;
        }
    }
}