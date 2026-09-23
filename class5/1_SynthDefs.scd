//We've been getting used to making sounds with node Proxy like this:

(
~swirl = NodeProxy.new.play;
~swirl.source={|freq=50|
	var out, out1, out2, env, lfo;
	freq=freq.midicps;
	lfo = SinOsc.kr(freq/10000).range(0, 1);
	out1 = VarSaw.ar(freq, 0, lfo).range(0,0.1);
	out2 = VarSaw.ar(freq*LFNoise1.kr(1).range(1.001, 1.015), 0, lfo).range(0,0.1);
	out = out1+out2;
	out = out;
}
)

~swirl.play
~swirl.stop
~swirl.set(\freq, 60)

//the more conventional way to do this with supercollider is using the structure of
//the SynthDef
// Whereas NDef and NodeProxy can be *anything*, synthdefs are specficially for making sound,
//with synthesizers.

//So first let's go over the syntax.
//you name it with \ not ~
(
SynthDef(\swirl, {|freq=50|
	var out, out1, out2, env, lfo;
	lfo = SinOsc.kr(freq/10000).range(0, 1);
	out1 = VarSaw.ar(freq, 0, lfo).range(0,0.1);
	out2 = VarSaw.ar(freq*LFNoise1.kr(1).range(1.001, 1.015), 0, lfo).range(0,0.1);
	out = out1+out2;
	Out.ar([0,1], out);
}).add
)

//you'll notice most importantly i added a new line, Out.ar.
//this says, to what channel are you sending, and what are you sending.

x = Synth(\swirl, [\freq, 60]);
x = Synth(\swirl, [\freq, 72]);
x.free
x.set(\freq, 71)

//the next habit we'll start getting into is adding an envelope to out sound.

(
s.freeAll;   // clear any old synths still hanging around
SynthDef(\swirl, {|freq=100, gate=1| //you need "gate" here!
	var out, out1, out2, env, lfo;
	freq=freq;
	lfo = SinOsc.kr(freq/10000).range(0, 1);
	out1 = VarSaw.ar(freq, 0, lfo).range(0,0.1);
	out2 = VarSaw.ar(freq*LFNoise1.kr(1).range(1.001, 1.015), 0, lfo).range(0,0.1);
	out = out1+out2;
	env = EnvGen.kr(Env.adsr(1.1, 0.1, 0.8, 0.1), gate, doneAction: 0); //here's the envelope. note, doneaction of 2 would free the synth, so this is important.
	out = out*env; //and here's the AM modulation of the envelope with that signal.
	Out.ar([0,1], out);
}).add
)


// 2. PLAY: run these one line at a time
x = Synth(\swirl);   // one synth, silent until gate = 1
x.set(\gate, 1);              // note on (middle C)
x.set(\freq, 72);             // change pitch while it's sounding
x.set(\gate, 0);   .           // note off; the synth stays alive
x.set(\freq, 200, \gate, 1);   // play again, no errors
x.set(\gate, 0);

(Pbind(\instrument, \swirl,
	\freq, Prand([100,200,250,300,600,700,1000],inf),
	\dur, Pbrown(0.125,1,0.125,inf),
	\amp, Pwhite(0.1,9,inf)
).play;)

//use midinote argumment
(Pbind(\instrument, \swirl,
	\midinote, Prand([60,62,65,67,70,72,75],inf),
	\dur, Pbrown(0.125,1,0.125,inf),
	\legato, Pwhite(0.4,1.1,inf),
	\amp, Pwhite(0.1,9,inf)
).play;)

//use note argument
(Pbind(\instrument, \swirl,
	\note, Prand([0, 2, 4, 5, 9, 12],inf),
	\octave, Prand([4,4,5],inf),
	\dur, Pbrown(0.125,1,0.125,inf)/4,
	\amp, Pwhite(0.1,9,inf)
).play;)

(
SynthDef(\behrman, {|freq=100, portamento=1.5, amp=0.1, pan=0, gate=1|
    var voice, env;
    freq = Lag.kr(freq, portamento);
    voice = Splay.ar(VarSaw.ar([freq, freq*1.5, freq*4, freq*6], 0, 0.5, amp));
    // ADSR envelope controlled by gate
    env = EnvGen.kr(Env.adsr(0.1, 0.1, 0.8, 0.5), gate, doneAction: 0);
    voice = voice * env;
    Out.ar(0, Pan2.ar(voice, pan));
}).add;
)

x = Synth(\behrman, [\freq, 400])

x = Synth(\behrman, [\freq, 200])

x.set(\freq, 100)
x.release

(Pbind(\instrument, \behrman,
	\freq, Prand([100, 75, 200, 400],inf),
	\legato, 1.1,
	\octave, 4,
	\dur, Pbrown(0.5,3,0.5,inf)/2,
	\amp, Pwhite(0.1, 0.5, inf)
).play;)

//or drive it with note
(Pbind(\instrument, \behrman,
	\freq, Prand([100, 75, 200, 400],inf),
	\legato, 1.1,
	\octave, 4,
	\dur, Pbrown(0.5,3,0.5,inf)/2,
	\amp, Pwhite(0.1, 0.5, inf)
).play;)


(
Pmono(\behrman,
	\freq, Prand([100, 200, 250, 300, 600, 700, 1000], inf),
	\octave, 1,
	\dur, Pbrown(1, 3, 0.25, inf),
	\amp, Pwhite(0.1, 0.9, inf)
).play;
)

//or explicitly driving the note argument instrad of octave
(
p = Pmono(\behrman,
	\note, Prand([-12, -5, 0, 3, 7, 12], inf),
	\portamento, Pseq([0, 0, 0, 1, 0, 0, 3],inf),
	\octave, 4,          // 5 = normal, 4 = one down, 6 = one up
	\dur, Pgauss(2, 0.75, inf), //gaussian takes the mean and the deviation around the mean
	\legato, 1.1,
	\amp, Pwhite(0.1, 0.9, inf)
).play;
)

(
SynthDef(\peaky,
{ |freq=100| var levels, times, doneAction, env, a;

	// THIS IS JUST THE TEST SOUND
	a = PinkNoise.ar;
	a = RLPF.ar(a, [freq*5, freq*6], 0.01).softclip * 0.1;

	// HERE IS THE ENVELOPE
	doneAction = 2;				// when the envelope finishes, it will dispose of the synth
	levels = [0,1,1,0];			// envelope will begin at 0 go to 1, stay there and then decay
	times = [0.2, 0.4, 0.1];	// 0 to 1: 0.2 seconds, 1 to 1: 0.4 seconds, 1 to 0: 0.1 seconds
	env = Env(levels, times);	// define the envelope
	env = env.kr(doneAction);	// make it run as a UGen
	env = env.lincurve(0, 1, 0,4, 3); // read the SimpleNumber helpfile discussion of lincurve

	// applying the envelope to the sound
	a = env * a;
	Out.ar([0,1], a);
}).add
)


// So, if you followed thus far, you should be able to throw sounds from the server into the sounding world, because you have two or three synthdefs loaded.

r = Synth(\peaky, [\freq, 200])
//like this!
//or
x = Synth(\behrman, [\freq, 400])
//this!

z = Synth(\swirl, [\freq, 60]);
z = Synth(\swirl, [\freq, 72]);
z.release
z.set(\freq, 71)
//or this!