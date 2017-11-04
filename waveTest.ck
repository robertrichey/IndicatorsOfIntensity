RideData data;
// launch FM wave in background
ShiftingFMWave wave;
data.getGrains(5) @=> wave.grains;
900000 => wave.totalDuration;
spork ~ wave.play();
spork ~ wave.turnOn(100, 0, 45);
5000::ms => now;