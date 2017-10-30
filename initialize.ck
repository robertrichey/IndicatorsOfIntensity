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
//Machine.add(me.dir() + "/MinMaxSTK.ck");

/*
chuck midi => ableton => chuck audio(?)
consult dr cooper about sound quality
use of filters on ugens
panning
different data sets
Based number of notes/velocity/rhythmic complexity on data?
Set gain function for FM wave?
Use array of SndBuf, one for each drum rate
Adjust FM gain to match MIDI instruments
Organize code before main in MinMaxMIDI, reorder functions
*/