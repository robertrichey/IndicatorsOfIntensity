// class files
Machine.add(me.dir() + "/Power.ck");
Machine.add(me.dir() + "/Cadence.ck");
Machine.add(me.dir() + "/HeartRate.ck");
Machine.add(me.dir() + "/Speed.ck");
Machine.add(me.dir() + "/Sample.ck");
Machine.add(me.dir() + "/SampleGrains.ck");
Machine.add(me.dir() + "/RideData.ck");
Machine.add(me.dir() + "/ShiftingFMWave.ck");

// performance file (~15 minutes)
Machine.add(me.dir() + "/MinMaxMIDI.ck");

/*
chuck midi => ableton => chuck audio(?)
consult Dr cooper about sound quality in DAW?
use of filters on ugens
panning
different data sets
Based number of notes/velocity/rhythmic complexity on data?
Set gain function for FM wave? base on gain of drums
Use array of SndBuf, one for each drum rate
Improve quality of drum sound
Control volume of MIDI flute
Send all audio to ableton, use master reverb
Break drum/FM wave method into smaller methods
Extract ride data from MinMax to seperate class
Set performance duration in one file (make param in FM class)
*/