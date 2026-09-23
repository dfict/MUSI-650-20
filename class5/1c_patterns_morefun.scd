SCLOrkSynths.gui;

(Pbind(\instrument, (Prand([\kalimba, \kik3, \snare1], inf)),
	\note, Pseq([0, 4, 7], inf),
	\octave, Pbrown(1, 4, 1, inf),
	\amp, Pwhite(0.1,0.9),
	\dur, Prand([Pseq([0.1,0.1,0.1,0.1],1), 0.2, 0.3, 0.4], inf)).play;

Pbind(\instrument, \sillyVoice,
	\note, Pseq([0, 2, 7, 4, 9], inf),
	\octave, 5,
	\amp, Pwhite(0.2, 0.9),
	\legato, Pwhite(1.5, 3.0),
	\vowel, Pwhite(0.0, 3.0),
	\dur, Pseq([2, 3, 1.5, 2.5, 4], inf)
).play;

)


a= Synth(\sillyVoice)



(
Routine {
	if(~synthsLoaded.isNil or: { ~synthsLoaded == false }) {
		SCLOrkSynths.load;
		~synthsLoaded = true;
	};
	1.0.wait;
	Pbind(
		\instrument, Prand([\kalimba, \kik3, \snare1], inf),
		\note, Pseq([0, 4, 7], inf),
		\octave, Pbrown(1, 4, 1, inf),
		\amp, Pwhite(0.1, 0.9),
		\dur, Prand([Pseq([0.1, 0.1, 0.1, 0.1], 1), 0.2, 0.3, 0.4], inf)
	).play;
}.play;
)