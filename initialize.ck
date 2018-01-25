// Support classes
Machine.add(me.dir() + "/Power.ck");
Machine.add(me.dir() + "/Cadence.ck");
Machine.add(me.dir() + "/HeartRate.ck");
Machine.add(me.dir() + "/Speed.ck");
Machine.add(me.dir() + "/Sample.ck");
Machine.add(me.dir() + "/SampleGrains.ck");
Machine.add(me.dir() + "/RideData.ck");
Machine.add(me.dir() + "/ShiftingFMWave.ck");
Machine.add(me.dir() + "/ShiftingFMWave1.ck");
Machine.add(me.dir() + "/ShiftingFMWave2.ck");
Machine.add(me.dir() + "/ShiftingFMWave3.ck");
Machine.add(me.dir() + "/ShiftingVoice.ck");

// Performance classes (~16 minutes)
Machine.add(me.dir() + "/PowerZones.ck");
Machine.add(me.dir() + "/MinMaxMIDI.ck");
Machine.add(me.dir() + "/bikeSounds.ck");


/*
Map voice samples to shifting based on content (power/speed/hr)
Access RideData from outside ShiftingVoice 
Fix bug related to FM wave extending beyond samples - silence for last 5-10%?
Always end w/ chord in guitar
***Make each instrument its own object?***
sound quality in DAW?
Fix early voice entry, clarify algo
integrate bike and voice samples with rest of code
how to handle reuse of functions?
DOCUMENT, remove stale comments
Use Ableton suite for better MIDI instruments?
use of filters on ugens
panning
make use of multiple FM waves?
different data sets
Based number of notes/velocity/rhythmic complexity on data?
Set gain function for FM wave? base on gain of drums
Improve quality of drum sound
Control volume of MIDI flute
Break drum/FM wave method into smaller methods
Set performance duration in one file (make param in FM class)
*/