// Has a lower, more restricted modulator and longer envelope than origonal FMWave

public class ShiftingFMWave2 extends ShiftingFMWave {
    fun void play() {
        totalDuration / grains.numberOfGrains => float shiftDur;
        
        // Play sound based on grain for total duration
        for (0 => int i; i < grains.numberOfGrains - 1; i++) {
            // 36, 94
            Std.mtof(getTransformation(grains.minCadence, grains.maxCadence, 24, 82, grains.cadence[i])) => 
            float startCarFreq;
            
            Std.mtof(getTransformation(grains.minCadence, grains.maxCadence, 24, 82, grains.cadence[i + 1])) => 
            float endCarFreq;
            
            // 
            getTransformation(grains.minPower, grains.maxPower, 10, 100, grains.power[i]) => 
            float startModFreq;
            
            getTransformation(grains.minPower, grains.maxPower, 10, 100, grains.power[i + 1]) => 
            float endModFreq;
            
            // 0.08, 0.15 
            getTransformation(grains.minHeartRate, grains.maxHeartRate, 0.15, 0.35, grains.heartRate[i]) => 
            float startCarGain;
            
            getTransformation(grains.minHeartRate, grains.maxHeartRate, 0.15, 0.35, grains.heartRate[i + 1]) => 
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