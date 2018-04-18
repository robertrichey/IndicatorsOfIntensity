/**
 * Creates an object that provides access to the data recorded during a given ride
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
    
    
    //---------- Calculate minimums, maximums, and averages ----------//
    // NOTE: does not currently calculate minimum values
    
    samples[0].power.current => float totalPower;
    samples[0].speed.current => float totalSpeed;
    samples[0].heartRate.current => float totalHeartRate;
    samples[0].cadence.current => float totalCadence;
    
    samples[0].power.current => int minPower;
    samples[0].power.current => int maxPower;
    
    samples[0].speed.current => float minSpeed;
    samples[0].speed.current => float maxSpeed;
    
    samples[0].heartRate.current => int minHeartRate;
    samples[0].heartRate.current => int maxHeartRate;
    
    samples[0].cadence.current => int minCadence;
    samples[0].cadence.current => int maxCadence;
    
    
    for (1 => int i; i < numberOfSamples; i++) {    
        
        // Power
        //Math.min(minPower, samples[i].power.current) => minPower;
        
        if (samples[i].power.current > maxPower) {
            samples[i].power.current => maxPower;
        }
        maxPower => samples[i].power.max;
        
        samples[i].power.current +=> totalPower;
        Std.ftoi(getAverage(totalPower, i)) => samples[i].power.average;
        
        // Speed
        //Math.min(minSpeed, samples[i].speed.current) => minSpeed;
        
        if (samples[i].speed.current > maxSpeed) {
            samples[i].speed.current => maxSpeed;
        }
        maxSpeed => samples[i].speed.max;
        
        samples[i].speed.current +=> totalSpeed;
        getAverage(totalSpeed, i) => samples[i].speed.average;
        
        // Heart rate
        //Std.ftoi(Math.min(minHeartRate, samples[i].heartRate.current)) => minHeartRate;
        
        if (samples[i].heartRate.current > maxHeartRate) {
            samples[i].heartRate.current => maxHeartRate;
        }
        maxHeartRate => samples[i].heartRate.max;
        
        samples[i].heartRate.current +=> totalHeartRate;
        getAverage(totalHeartRate, i) => samples[i].heartRate.average;
        
        
        // Cadence
        //Std.ftoi(Math.min(minCadence, samples[i].cadence.current)) => minCadence;
        
        if (samples[i].cadence.current > maxCadence) {
            samples[i].cadence.current => maxCadence;
        }
        maxCadence => samples[i].cadence.max;
        
        samples[i].cadence.current +=> totalCadence;
        Std.ftoi(getAverage(totalCadence, i)) => samples[i].cadence.average;
    }
    
    // <<< "MIN/MAX:", minPower, maxPower, minSpeed, maxSpeed, minCadence, maxCadence, minHeartRate, maxHeartRate >>>;
    
    /**
     *  Returns an array of Samples collected from the data set
     */
    fun Sample[] getSamples() {
        return samples;
    }
    
    /**
     * Returns a SampleGrains object based on the desired grain size
     */    
    fun SampleGrains getGrains(int grainSize) {
        // Round down to nearest multiple of grainSize
        numberOfSamples - (numberOfSamples % grainSize) => int roundedSamples;
        roundedSamples / grainSize => int arraySize;

        // Create arrays to hold the averages over grainSize samples
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
        
        // Calculate averages and populate arrays
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
        
        // Create SampleGrains object, assign values, and return it
        SampleGrains grains;
        
        arraySize => grains.numberOfGrains;
        
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
    
    /**
     * Returns an average based on sum and numItems
     */
    fun float getAverage(float sum, int numItems) {
        return sum / numItems;
    }
    
    /**
     * Returns the minimum value in an array
     */
    fun float getMin(float arr[]) {
        arr[0] => float min;
        
        for (1 => int i; i < arr.size(); i++) {
            if (arr[i] < min) {
                arr[i] => min;
            }
        }
        return min;
    }
 
    /**
     * Returns the maximum value in an array
     */    
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