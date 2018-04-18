/**
 * Subclass of ShiftingFMWave. Waveform continually shifts based on data from a rider's
 * speed, power, heart rate, and cadence
 */
public class ShiftingFMWave3 extends ShiftingFMWave {
    [0.05, 0.17] @=> baseGains;
    
    /**
     * Use cycling data to transform an FM wave over totalDuration milliseconds
     */
    fun void play() {
        totalDuration / grains.numberOfGrains => float shiftDur;
        getGain() @=> curGains;

        // Play sound based on grain for total duration
        for (0 => int i; i < grains.numberOfGrains - 1; i++) {
            Std.mtof(getTransformation(grains.minHeartRate, grains.maxHeartRate, 67, 96, grains.heartRate[i])) => 
            float startCarFreq;
            
            Std.mtof(getTransformation(grains.minHeartRate, grains.maxHeartRate, 67, 96, grains.heartRate[i + 1])) => 
            float endCarFreq;
            
            
            getTransformation(grains.minSpeed, grains.maxSpeed, 120, 500, grains.speed[i]) => 
            float startModFreq;
            
            getTransformation(grains.minSpeed, grains.maxSpeed, 120, 500, grains.speed[i + 1]) => 
            float endModFreq;
            
            
            getTransformation(grains.minCadence, grains.maxCadence, curGains[0], curGains[1], grains.cadence[i]) => 
            float startCarGain;
            
            getTransformation(grains.minCadence, grains.maxCadence, curGains[0], curGains[1], grains.cadence[i + 1]) => 
            float endCarGain;
            
            
            getTransformation(grains.minPower, grains.maxPower, 350, 1200, grains.power[i]) => 
            float startModGain;
            
            getTransformation(grains.minPower, grains.maxPower, 350, 1200, grains.power[i + 1]) => 
            float endModGain;
            
            spork ~ shiftCarPitch(startCarFreq, endCarFreq, shiftDur);
            spork ~ shiftCarGain(startCarGain, endCarGain, shiftDur);
            spork ~ shiftModPitch(startModFreq, endModFreq, shiftDur);
            spork ~ shiftModGain(startModGain, endModGain, shiftDur);
            shiftDur::ms => now;
        }
    }
}