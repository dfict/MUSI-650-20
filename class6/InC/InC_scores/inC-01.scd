
Pbindef.clear;
~mySynth = "default"; // choose a synth here

(
Pbindef.clear;
//~clock = TempoClock.new(2).permanent_(true); // if not using a shared clock
~mySynth = "bassWarsaw"; // choose a synth here
//~mySynth = "default"; // or use the default if you're just testing!
~clock = LinkClock(2).latency_(Server.default.latency); //if you're using a network clock'
~clock.tempo_(2) //change tempo if you need it.
)


// ORIGINAL (do not live code on this one)
(
Pbindef(\p1,
	\instrument, ~mySynth,
    \degree, Pseq([0, 2, 0, 2, 0, 2], inf),
    \dur, Pseq([0.05, 0.95], inf),
	\octave, 3,
    \amp, 0.5,
    \legato, 1
).play(~clock, quant: 1).quant = 1;
)

// COPY (live code on THIS one instead)
(
Pbindef(\p1,
	\instrument, ~mySynth,
    \degree, Pseq([0, 2, 0, 2, 0, 2], inf),
    \dur, Pseq([0.05, 0.95], inf),
    \amp, 0.5,
    \legato, 1
).play(~clock, quant: 1).quant = 1;
)

