// Use cycling data set
RideData data;
data.getSamples() @=> Sample samples[];
samples.size() => int numberOfSamples;

ShiftingVoice voice;

// Set length of piece
960000 => float totalDuration;
totalDuration / numberOfSamples => float sampleRate;

250 => int ftp;
0 => int previousZone;
1 => int currentZone;
0 => int count;

0 => int current;
0 => int currentCount;
0 => int change;

<<< voice.isOff >>>;

for (0 => int i; i < numberOfSamples; i++) {
    /*getZone(samples[i-1].power.current) => int previous;
    getZone(samples[i].power.current) => int current;
    
    if (previous != 0 && current != 0) {
        if (previous == current) {
            count++;
        }
        else {
            0 => count;
        }
        if (i % 10 == 0) {
            <<< "previous", previous, samples[i-1].power.current >>>; 
            <<< "current", current, samples[i].power.current >>>; 
            <<< "count", count >>>; 
            <<< " ", "" >>>; 
        }
    }*/
    
    if (samples[i].power.current != 0) {
        samples[i].power.current +=> current;
        currentCount++;
    }
    
    if (currentCount == 30) {
        //<<< i >>>;
        //<<< "Current total", current >>>;
        getZone(current / 30.0) => int currentZone;
        
        if (currentZone == previousZone) {
            count++;
        }
        else {
            if (Math.randomf() > 0.4 && voice.isOff) {
                spork ~ voice.play();
            }
            <<< "count", count, i, ++change >>>; 
            0 => count;
        }
        //<<< "previous", previousZone >>>; 
        //<<< "current", currentZone >>>; 
        //<<< "count", count >>>; 
        //<<< " ", "" >>>; 
        
        currentZone => previousZone;
        0 => current;
        0 => currentCount;
    }
    sampleRate::ms => now;
}
<<< "count", count >>>; 

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