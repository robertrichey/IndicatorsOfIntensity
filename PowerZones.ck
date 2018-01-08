/**
 * Plays a ShiftingVoice object when the rider changes power zones
 */

public class PowerZones {
    // Use cycling data set
    RideData data;
    data.getSamples() @=> Sample samples[];
    samples.size() => int numberOfSamples;
    
    ShiftingVoice voice;
    
    // Set length of piece
    float totalDuration;
    
    250 => int ftp;
    1 => int previousZone;
    1 => int currentZone;
    
    0 => float currentTotal;
    0 => int sampleCount;
    
    30 => int sampleSize;
    
    /**
     * Play voice if the current zone is not equal to the previous zone
     */
    fun void play() {
        totalDuration / numberOfSamples => float sampleRate;
        
        // Loop through samples at sampleRate, calculating averages and checking current zone against previous zone
        for (0 => int i; i < numberOfSamples; i++) {
            samples[i].power.current +=> currentTotal;
            sampleCount++;
                        
            if (sampleCount == sampleSize) {
                getZone(currentTotal / sampleSize) => int currentZone;
                
                // Play voice 80% of the time
                // 300 prevents voice from entering too early, ignores first 300 samples
                if (currentZone != previousZone) {
                    if (Math.randomf() > 0.2 && voice.isOff && i > 300) {
                        spork ~ voice.play();
                    }
                    currentZone => previousZone;
                }
                
                0 => currentTotal;
                0 => sampleCount;
            }
            sampleRate::ms => now;
        }
    }
    
    /**
     * Returns the power zone based on a given wattage
     */
    fun int getZone(float power) {
        int zone;
        
        if (power < ftp * 0.55) {
            1 => zone;
        }
        else if (power < ftp * 0.75) {
            2 => zone;
        }
        else if (power < ftp * 0.90) {
            3 => zone;
        }
        else if (power < ftp * 1.05) {
            4 => zone;
        }
        else if (power < ftp * 1.20) {
            5 => zone;
        }
        else {
            6 => zone;
        }
        return zone;
    }
}