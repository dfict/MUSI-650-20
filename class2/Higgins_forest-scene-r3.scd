(
// ==========================================
// 1. SOUND DEFINITIONS (SYNTHDEFS)
// ==========================================

// Bird 1: Nearby, crisp, grounded left
SynthDef(\bird1, { |out = 0, pan = -0.5, amp = 0.4|
	var sig, freqenv, env;
	env = EnvGen.ar(Env.perc(0.01, 0.35, amp, -8), doneAction: 2);
	freqenv = EnvGen.ar(Env([Rand(1200, 2500), Rand(2800, 4500), Rand(1200, 2000)], [0.08, 0.08]));
	sig = SinOsc.ar(freqenv, 0, env);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

// Bird 2: Distant, soft, spatial reverb right
SynthDef(\bird2, { |out = 0, pan = 0.6, amp = 0.12|
	var sig, freqenv, env;
	env = EnvGen.ar(Env.perc(0.08, 1.2, amp, -4));
	freqenv = EnvGen.ar(Env([Rand(2200, 3800), Rand(3800, 5000), Rand(1800, 3000)], [0.15, 0.15]));
	sig = SinOsc.ar(freqenv, 0, env);
	sig = Pan2.ar(sig, pan);
	sig = FreeVerb2.ar(sig[0], sig[1], mix: 0.5, room: 0.8, damp: 0.9);
	sig = LPF.ar(sig, 3500);
	DetectSilence.ar(sig, amp: 0.0001, time: 0.2, doneAction: 2);
	Out.ar(out, sig);
}).add;

// Bird 3: Flying Warbler across stereo field with variable distance
SynthDef(\bird3_warbler, { |out = 0, amp = 0.25, dur = 3.8, startPan = -0.9, endPan = 0.9, dist = 0.0|
	var sig, freq, env, pan, warble;
	pan = Line.kr(startPan, endPan, dur);
	freq = EnvGen.kr(Env(
		[3500, 5200, 3800, 6000, 4200, 6200, 4500, 6400, 4000, 5800, 3200],
		[0.10, 0.06, 0.04, 0.04, 0.04, 0.04, 0.04, 0.06, 0.12, 1.2],
		\sine
	));
	warble = SinOsc.kr(38) * 350 * EnvGen.kr(Env([0, 0, 1, 1, 0], [0.2, 0.1, 1.0, 0.5]));
	env = EnvGen.kr(Env(
		[0, 0.8, 0.05, 0.9, 0.1, 0.9, 0.1, 0.95, 0.05, 0.7, 0],
		[0.10, 0.06, 0.04, 0.04, 0.04, 0.04, 0.04, 0.06, 0.12, 1.2]
	));
	sig = SinOsc.ar(freq + warble) * env;
	sig = Pan2.ar(sig, pan);
	sig = sig * LinExp.kr(dist, 0.0, 1.0, amp, amp * 0.25);
	sig = FreeVerb2.ar(sig[0], sig[1], mix: dist.linexp(0.0, 1.0, 0.02, 0.65), room: 0.85, damp: 0.7);
	DetectSilence.ar(sig, amp: 0.0001, time: 0.2, doneAction: 2);
	Out.ar(out, sig);
}).add;

// Breeze: High leaf rustle, moves right to left, no low rumble
SynthDef(\breeze, { |out = 0, amp = 0.14, dur = 12|
	var sig, env, pan, filterCutoff;
	env = EnvGen.kr(Env.perc(dur * 0.4, dur * 0.6, amp, -2), doneAction: 2);
	pan = EnvGen.kr(Env([0.65, 0.7, -0.4], [dur * 0.6, dur * 0.4]));
	filterCutoff = LFNoise1.kr(0.3).exprange(1800, 5200);
	sig = PinkNoise.ar;
	sig = HPF.ar(sig, 800);
	sig = LPF.ar(sig, filterCutoff);
	sig = BPF.ar(sig, 2800, 1.5, add: sig * 0.4);
	sig = Pan2.ar(sig, pan) * env;
	Out.ar(out, sig);
}).add;

// Main Cicada: Center-ish abdominal rattle swell
SynthDef(\cicada, { |out = 0, amp = 0.06, dur = 18|
	var sig, env, pulse;
	env = EnvGen.kr(Env.sine(dur, amp), doneAction: 2);
	pulse = LFPulse.ar(45 + LFNoise1.kr(0.5).range(-4, 4), 0, 0.55);
	sig = BPF.ar(WhiteNoise.ar, 6800, 0.12) * pulse;
	sig = Pan2.ar(sig, Rand(0.1, 0.5)) * env;
	Out.ar(out, sig);
}).add;

// Distant Cicada: Off to far right, muffled
SynthDef(\cicada_distant, { |out = 0, amp = 0.025, dur = 16, pan = 0.85|
	var sig, env, pulse;
	env = EnvGen.kr(Env.sine(dur, amp), doneAction: 2);
	pulse = LFPulse.ar(48 + LFNoise1.kr(0.4).range(-3, 3), 0, 0.5);
	sig = BPF.ar(WhiteNoise.ar, 7200, 0.08) * pulse;
	sig = LPF.ar(sig, 4800);
	sig = Pan2.ar(sig, pan) * env;
	Out.ar(out, sig);
}).add;

// Katydid: High-frequency staccato clicks
SynthDef(\katydid, { |out = 0, amp = 0.12, pan = -0.4|
	var sig, env, pulse;
	env = EnvGen.kr(Env([0, 1, 0.05, 0.8, 0.05, 0.8, 0.05, 0.9, 0], [0.03, 0.02, 0.03, 0.02, 0.03, 0.02, 0.04]), doneAction: 2);
	pulse = Pulse.ar(55);
	sig = HPF.ar(WhiteNoise.ar, 7500) * pulse;
	sig = Pan2.ar(sig, pan) * env * amp;
	Out.ar(out, sig);
}).add;

// Peeper Array Element
SynthDef(\peeperFrog, {
	|out = 0, pan = 0.8, dist = 0.85, rate = 0.4,
	 startFreq = 2800, endFreq = 3400, amp = 0.10|

	var macroTrig, dynamicRate, peepEnv, pitchEnv, sig;

	macroTrig = Impulse.kr(rate);
	dynamicRate = rate * TRand.kr(0.80, 1.20, macroTrig);
	macroTrig = Impulse.kr(dynamicRate);

	peepEnv = EnvGen.kr(Env.perc(0.01, 0.12, curve: -2), macroTrig);
	pitchEnv = EnvGen.kr(Env([startFreq, startFreq, endFreq], [0, 0.10], [\step, \exponential]), macroTrig);

	sig = SinOsc.ar(pitchEnv) + (SinOsc.ar(pitchEnv * 2) * 0.05);
	sig = sig * peepEnv * amp;

	sig = LPF.ar(sig, dist.linlin(0.0, 1.0, 8000, 2000));
	sig = sig * dist.linlin(0.0, 1.0, 1.0, 0.15);

	sig = FreeVerb.ar(sig,
		mix: dist.linlin(0.0, 1.0, 0.05, 0.60),
		room: 0.85,
		damp: 0.4);

	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

// Solo Cricket Element
SynthDef(\soloCricket, {
	|out = 0, pan = 0.0, dist = 0.1, rate = 0.6, freq = 2400,
	 ringDecay = 0.306, trillDur = 0.55, wingSpeed = 38, pitchRatio = 1.25, amp = 0.15|

	var macroTrig, dynamicRate, burstEnv, pitchEnv, microImpulse, wingResonance, frictionNoise, sig;

	macroTrig = Impulse.kr(rate);
	dynamicRate = rate * TRand.kr(0.85, 1.15, macroTrig);
	macroTrig = Impulse.kr(dynamicRate);

	burstEnv = EnvGen.kr(Env.perc(0.105, trillDur, curve: 1), macroTrig);
	microImpulse = Impulse.ar(wingSpeed) * burstEnv;
	pitchEnv = EnvGen.kr(Env([freq, freq, freq * pitchRatio], [0, trillDur], [\step, \exponential]), macroTrig);

	wingResonance = Ringz.ar(microImpulse, pitchEnv, ringDecay)
	              + (Ringz.ar(microImpulse, pitchEnv * 1.17, 0.04) * 0.35);

	frictionNoise = BPF.ar(WhiteNoise.ar(), pitchEnv * 1.4, 0.3) * burstEnv * 0.12;

	sig = (wingResonance + frictionNoise) * amp;

	sig = LPF.ar(sig, dist.linlin(0.0, 1.0, 9500, 1600));
	sig = sig * dist.linlin(0.0, 1.0, 1.0, 0.2);

	sig = Pan2.ar(sig, pan);
	sig = FreeVerb2.ar(
		sig[0], sig[1],
		mix: dist.linlin(0.0, 1.0, 0.02, 0.45),
		room: 0.6,
		damp: 0.5
	);

	Out.ar(out, sig);
}).add;
)



(x = Synth.new(\soloCricket, [\rate, 2]);
x.set(\rate, 1);
x.free)

// ==========================================
// 2. MASTER FOREST SEQUENCER
// ==========================================

(
Routine({

	// 1. Breeze
	fork {
		loop {
			Synth(\breeze, [\dur, rrand(10.0, 14.0)]);
			rrand(14.0, 22.0).wait;
		}
	};

	// 2. Distant Right Cicada
	fork {
		2.0.wait;
		loop {
			Synth(\cicada_distant, [\dur, rrand(12.0, 16.0)]);
			rrand(18.0, 22.0).wait;
		}
	};

	// 3. Grounded Bird 1
	fork {
		0.5.wait;
		loop {
			if (0.5.coin) {
				Synth(\bird1, [\pan, -0.5 + rrand(-0.05, 0.05)]);
			};
			rrand(4.0, 10.0).wait;
		}
	};

	// 4. Distant Bird 2
	fork {
		1.8.wait;
		loop {
			if (0.5.coin) {
				Synth(\bird2, [\pan, 0.6 + rrand(-0.03, 0.03)]);
			};
			rrand(5.0, 12.0).wait;
		}
	};

	// 5. Katydid
	fork {
		1.0.wait;
		loop {
			if (0.5.coin) {
				rrand(2, 4).do({
					Synth(\katydid, [\pan, rrand(-0.7, 0.7)]);
					rrand(0.15, 0.35).wait;
				});
			};
			rrand(7.0, 14.0).wait;
		}
	};

	// 6. Flying Warbler (Bird 3)
	fork {
		4.0.wait;
		loop {
			if (0.4.coin) {
				var dir = [-0.9, 0.9].scramble;
				var flightDist = rrand(0.0, 0.85);
				Synth(\bird3_warbler, [
					\startPan, dir[0],
					\endPan, dir[1],
					\dur, rrand(3.5, 4.5),
					\dist, flightDist
				]);
			};
			rrand(18.0, 32.0).wait;
		}
	};

	// 7. Main Cicada
	fork {
		12.0.wait;
		loop {
			Synth(\cicada, [\dur, rrand(14.0, 20.0)]);
			rrand(15.0, 30.0).wait;
		}
	};

	// 8. Staggered Cricket Array Launcher
	fork {
		var cricketsData = [
			[6700, 0.10,  0.15, 0.65, 0.22],
			[6400, 0.25, -0.30, 0.58, 0.26],
			[6200, 0.45,  0.50, 0.62, 0.24],
			[5700, 0.75, -0.85, 0.48, 0.28],
			[5300, 0.90,  0.90, 0.52, 0.30]
		];

		~cricketArray = cricketsData.collect({ |cfg|
			var synth = Synth(\soloCricket, [
				\freq, cfg[0],
				\dist, cfg[1],
				\pan, cfg[2],
				\rate, cfg[3],
				\trillDur, cfg[4],
				\ringDecay, 0.11,
				\wingSpeed, 38,
				\amp, 0.15
			]);

			rrand(0.2, 0.9).wait;
			synth;
		});

		"Spatial cricket array active.".postln;
	};

	// 9. Launch Distant Pond Choir
	fork {
		var peepersData = [
			[3200, 3300, 1.00, 0.90, 0.58],
			[3500, 4000, 0.93, 1.00, 0.42],
			[3100, 3700, 0.88, 0.98, 0.38],
			[3100, 3700, 0.75, 0.95, 0.66],
			[3200, 3300, 0.90, 0.94, 0.48],
			[3500, 4000, 0.91, 0.93, 0.62],
			[3100, 3700, 0.87, 0.89, 0.28],
			[3100, 3700, 0.75, 0.90, 0.36],
			[3200, 3300, 1.00, 0.90, 0.58],
			[3500, 4000, 0.93, 1.00, 0.42],
			[3100, 3700, 0.88, 0.98, 0.38],
			[3100, 3700, 0.75, 0.95, 0.66],
			[3200, 3300, 0.90, 0.94, 0.48],
			[3500, 4000, 0.91, 0.93, 0.62],
			[3100, 3700, 0.87, 0.89, 0.28],
			[3100, 3700, 0.75, 0.90, 0.36]
		];

		~peeperArray = peepersData.collect({ |cfg|
			var synth = Synth(\peeperFrog, [
				\startFreq, cfg[0],
				\endFreq, cfg[1],
				\dist, cfg[2],
				\pan, cfg[3],
				\rate, cfg[4],
				\amp, 0.10
			]);

			rrand(0.3, 1.2).wait;
			synth;
		});

		"Pond choir active.".postln;
	};

}).play;
)