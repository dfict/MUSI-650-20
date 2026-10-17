// piece template
// based on the structure of "bottom right hand #20"
(
s.waitForBoot {

	// ---------- SOUNDS ----------

	// drones: plain functions returning a stereo signal.
	// these get swapped into the Ndef layer by ~syn.
	~droneA = { SinOsc.ar([220, 221], 0, 0.1) };
	~droneB = { LFTri.ar([330, 333], 0, 0.08) };
	~droneC = { BPF.ar(PinkNoise.ar(0.3.dup), 800, 0.3) };
	~quiet  = { Silent.ar.dup };

	// gestures: functions that take a length in seconds
	// and return an event pattern lasting that long.
	~blips = { |long|
		Pfindur(long, Pbind(
			\degree, Pwhite(0, 7),
			\dur, 0.25,
			\amp, 0.1
		))
	};

	~bass = { |long|
		Pfindur(long, Pbind(
			\octave, 3,
			\degree, Pseq([0, 3, 4], inf),
			\dur, 2,
			\amp, 0.15
		))
	};


	// ---------- MACHINERY ----------

	Ndef(\a, ~quiet);
	Ndef(\a).fadeTime = 7;
	Ndef(\a).play;

	// switch the drone, then hold for t seconds
	~syn = { |p, t| Prout({ Ndef(\a, p); t.wait }) };

	// silence in an event layer for t seconds
	~gap = { |t| Pbind(\type, \rest, \dur, Pseq([t], 1)) };


	// ---------- SCORE ----------

	~score = Ppar([

		// layer 1: drones
		Pseq([
			~syn.(~droneA, 10),
			~syn.(~droneB, 10),
			~syn.(~droneC, 10),
			~syn.(~quiet, 5)       // fade out at the end
		]),

		// layer 2: gestures
		Pseq([
			~blips.(10),
			~bass.(12)
		]),

		// layer 3: enters late
		Pseq([
			~gap.(40),
			  Ppar([~syn.(~droneA, 6),~syn.(~droneB, 4),~syn.(~droneC, 2)]), //use Ppar to group multiple layers at once
	])
	]);

	~player = ~score.play(TempoClock(1));
};
)


// stop everything
(
~player.stop;
Ndef(\a).release(5);
)
