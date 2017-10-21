/**
* TODO: description
*/

public class RideData {    
    FileIO file;
    
    // Get total number of samples and initialize array
    file.open("textfiles/numberOfSamples.txt", FileIO.READ);
    
    file => int numberOfSamples;
    Sample samples[numberOfSamples];
    file.close();
    
    // Read power data into array
    file.open("textfiles/power.txt", FileIO.READ);
    
    for (0 => int i; i < numberOfSamples; i++) {
        file => samples[i].power.current;
    }
    file.close();
    
    
    // Read speed data into array
    file.open("textfiles/speed.txt", FileIO.READ);
    
    for (0 => int i; i < numberOfSamples; i++) {
        file => samples[i].speed.current;
    }
    file.close();
    
    
    // Read heart rate data into array
    file.open("textfiles/heartRate.txt", FileIO.READ);
    
    for (0 => int i; i < numberOfSamples; i++) {
        file => samples[i].heartRate.current;
    }
    file.close();
    
    
    // Read cadence data into array
    file.open("textfiles/cadence.txt", FileIO.READ);
    
    for (0 => int i; i < numberOfSamples; i++) {
        file => samples[i].cadence.current;
    }
    file.close();
    
        
    fun SampleGrains getGrains(int grainSize) {
        // Round down to nearest grain
        numberOfSamples - (numberOfSamples % grainSize) => int roundedSamples;
        roundedSamples / grainSize => int arraySize;

        float powerAverages[arraySize];
        0.0 => float power;
        
        float speedAverages[arraySize];
        0.0 => float speed;
        
        float cadenceAverages[arraySize];
        0.0 => float cadence;
        
        float heartRateAverages[arraySize];
        0.0 => float heartRate;
        
        // Fill array with average of every grainSize samples
        0 => int index;
        0 => int count;
        
        for (0 => int i; i < roundedSamples; i++) {
            count++; 
            
            samples[i].power.current +=> power;
            samples[i].speed.current +=> speed;
            samples[i].cadence.current +=> cadence;
            samples[i].heartRate.current +=> heartRate;
            
            if (count % grainSize == 0 && count != 0) {
                power / grainSize => powerAverages[index];
                0 => power;
                
                speed / grainSize => speedAverages[index];
                0 => speed;
                
                cadence / grainSize => cadenceAverages[index];
                0 => cadence;
                
                heartRate / grainSize => heartRateAverages[index];
                0 => heartRate;
                
                index++;
                0 => count;
            }
        }
        
        SampleGrains grains;
        
        powerAverages @=> grains.power;
        speedAverages @=> grains.speed;
        cadenceAverages @=> grains.cadence;
        heartRateAverages @=> grains.heartRate;
        
        //Find minimums and maximums 
        getMin(powerAverages) => grains.minPower;
        getMax(powerAverages) => grains.maxPower;
        
        getMin(speedAverages) => grains.minSpeed;
        getMax(speedAverages) => grains.maxSpeed;
        
        getMin(cadenceAverages) => grains.minCadence;
        getMax(cadenceAverages) => grains.maxCadence;
        
        getMin(heartRateAverages) => grains.minHeartRate;
        getMax(heartRateAverages) => grains.maxHeartRate;
        
        return grains;
    }
    
    fun float getMin(float arr[]) {
        arr[0] => float min;
        
        for (1 => int i; i < arr.size(); i++) {
            if (arr[i] < min) {
                arr[i] => min;
            }
        }
        return min;
    }
    
    fun float getMax(float arr[]) {
        arr[0] => float max;
        
        for (1 => int i; i < arr.size(); i++) {
            if (arr[i] > max) {
                arr[i] => max;
            }
        }
        return max;
    }
}