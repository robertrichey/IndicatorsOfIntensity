// TODO: summarize class

public class ShiftingFMWave1 extends ShiftingFMWave {
    
    /**
     * Use cycling data to transform an FM wave over totalDuration milliseconds
     */
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
}