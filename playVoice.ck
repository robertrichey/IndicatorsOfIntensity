int values[13000 / 50];

0.9 => float threshold;
<<< values.size() / 1.618 >>>;
Std.ftoi(values.size() / 1.618) => int peakDensity;

0.8 / peakDensity => float thresholdDecrement;
0.8 / (values.size() - peakDensity) => float thresholdIncrement;

<<< 0.8 / peakDensity >>>;
<<< 0.8 / (values.size() - peakDensity) >>>;

now + 2000::ms => time later;

while (now < later) {
    <<< 1 >>>;
    500::ms => now;
}
1000 => float totalDuration;
totalDuration / values.size() => 

for (0 => int i; i < values.size(); i++) {
        Math.random2f(0.0, 1.0) => float chance;
        
        if (chance > threshold) {
            // play something
        }
        
    if (i < peakDensity) {
        thresholdDecrement -=> threshold;
    }
    else {
        thresholdIncrement +=> threshold;
    }
}