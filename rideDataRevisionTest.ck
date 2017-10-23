RideData data;

data.getGrains(25) @=> SampleGrains x;// @=> SampleGrains grains;
data.getGrains(10) @=> SampleGrains y;// @=> SampleGrains grains;

<<< data.numberOfSamples, x.power[6] >>>;
<<< data.numberOfSamples, y.power[3], y.numberOfGrains >>>;