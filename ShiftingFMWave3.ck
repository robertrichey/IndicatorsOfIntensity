// TODO: summarize class

public class ShiftingFMWave3 extends ShiftingFMWave {
    
    /**
     * Use cycling data to transform an FM wave over totalDuration milliseconds
     */
    fun void play() {
        totalDuration / grains.numberOfGrains => float shiftDur;
        
        // Play sound based on grain for total duration
        for (0 => int i; i < grains.numberOfGrains - 1; i++) {
            // 36, 94
            Std.mtof(getTransformation(grains.minCadence, grains.maxCadence, 63, 85, grains.cadence[i])) => 
            float startCarFreq;
            
            Std.mtof(getTransformation(grains.minCadence, grains.maxCadence, 63, 85, grains.cadence[i + 1])) => 
            float endCarFreq;
            
            // 
            getTransformation(grains.minSpeed, grains.maxSpeed, 40, 200, grains.speed[i]) => 
            float startModFreq;
            
            getTransformation(grains.minSpeed, grains.maxSpeed, 40, 200, grains.speed[i + 1]) => 
            float endModFreq;
            
            // 0.08, 0.15 
            getTransformation(grains.minHeartRate, grains.maxHeartRate, 0.1, 0.2, grains.heartRate[i]) => 
            float startCarGain;
            
            getTransformation(grains.minHeartRate, grains.maxHeartRate, 0.1, 0.2, grains.heartRate[i + 1]) => 
            float endCarGain;
            
            
            getTransformation(grains.minPower, grains.maxPower, 300, 1200, grains.power[i]) => 
            float startModGain;
            
            getTransformation(grains.minPower, grains.maxPower, 300, 1200, grains.power[i + 1]) => 
            float endModGain;
            
            spork ~ shiftCarPitch(startCarFreq, endCarFreq, shiftDur);
            spork ~ shiftCarGain(startCarGain, endCarGain, shiftDur);
            spork ~ shiftModPitch(startModFreq, endModFreq, shiftDur);
            spork ~ shiftModGain(startModGain, endModGain, shiftDur);

            shiftDur::ms => now;
        }
    }
}