// IN C
// by Terry Riley
// transcribed for Supercollider by Bruno Riviera
// well, actually, just the first 20 sections...the rest was finished by DF and Creative Musical Coding at Ramapo! in 2025



//load up all the synths .... if you want them...
SCLOrkSynths.gui

//evaluate these line by line...
(
Pbindef.clear;
//~clock = TempoClock.new(2).permanent_(true); // if not using a shared clock
~mySynth = "bassWarsaw"; // choose a synth here
~clock = LinkClock(2).latency_(Server.default.latency);
~clock.tempo_(2) //change tempo if you need it.
)
//





// ORIGINAL (do not live code on this one)
// only the conductor should play the clave. if you're an instrumentalist, go onward to inC-01 file to get ready to play the first measure.

(
Pbindef(\clave,
	\instrument, ~mySynth,
	\degree, (14),
    \dur, Pseq([0.5, 0.5], inf),
    \amp, Pgauss(0.5, 0.1, inf),
    \legato, Pwhite(1, 2, inf),
	\out, 0
).play(~clock, quant: 1).quant = 1;
)

/// LIVECODE (you can live code on this one)
(
Pbindef(\clave,
	\instrument, ~mySynth,
	\degree, (14),
    \dur, Pseq([0.5, 0.5], inf),
    \amp, Pgauss(0.5, 0.1, inf),
    \legato, Pwhite(1, 2, inf),
	\out, 0
).play(~clock, quant: 1).quant = 1;
)

//bizarre conductore controls.
~clock.tempo_(2) //change tempo if you need it.

