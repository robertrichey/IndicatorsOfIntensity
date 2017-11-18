// class files
Machine.add(me.dir() + "/Power.ck");
Machine.add(me.dir() + "/Cadence.ck");
Machine.add(me.dir() + "/HeartRate.ck");
Machine.add(me.dir() + "/Speed.ck");
Machine.add(me.dir() + "/Sample.ck");
Machine.add(me.dir() + "/SampleGrains.ck");
Machine.add(me.dir() + "/RideData.ck");
Machine.add(me.dir() + "/ShiftingFMWave.ck");
Machine.add(me.dir() + "/ShiftingVoice.ck");

// performance files (~16 minutes)
Machine.add(me.dir() + "/MinMaxMIDI.ck");
Machine.add(me.dir() + "/bikeSounds.ck");
Machine.add(me.dir() + "/PowerZones.ck");


/*
***Make each instrument its own object?***
sound quality in DAW?
Fix early voice entry, clarify algo
Use WCU computers for better MIDI instruments?
use of filters on ugens
panning
make use of multiple FM waves?
different data sets
Based number of notes/velocity/rhythmic complexity on data?
Set gain function for FM wave? base on gain of drums
Improve quality of drum sound
Control volume of MIDI flute
Send all audio to ableton, use master reverb
Break drum/FM wave method into smaller methods
Extract ride data from MinMax to seperate class
Set performance duration in one file (make param in FM class)
Extend performance to 20 minutes, decrease duration of FM wave
*/