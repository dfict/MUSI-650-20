

// aleatoric quartet
// mouse x controls density, excitation speed, and stereo movement
// mouse y controls resonance/decay and pitch randomness
// subtle independent random deviation added to mouse-controlled parameters
// each Dust event gets a randomly varied envelope
// excitation rate also wanders independently over time
// voice count randomly shifts between 1, 2, 3, and 4 voices
(
play({
	var amp, density, dmul, dadd, signal, xReverbDecay;
	var voiceCount, voiceChange;

	amp = 0.07;

	// Mouse X controls density.
	// Random deviation keeps the density from behaving mechanically.
	density = MouseX.kr(0.01, 1).pow(0.5)
		* (1 + (LFNoise1.kr(0.3) * 0.12));

	// calculate multiply and add for excitation probability
	dmul = density.reciprocal * 0.5 * amp;
	dadd = dmul.neg + amp;

	// Slowly choose a new number of active voices.
	// 30% = 1 voice
	// 20% = 2 voices
	// 20% = 3 voices
	// 30% = 4 voices
	voiceChange = Dust.kr(0.35);
	voiceCount = TWindex.kr(
		voiceChange,
		[0.3, 0.2, 0.2, 0.3]
	) + 1;

	signal = Mix.ar(
		// mix an array of 4 instruments
		Array.fill(4, { |i|
			var excitation, freq, dustRate, dust, env;
			var xRate, yPitch, yDecay, xCombDecay;

			// independent slow random deviation for X-controlled excitation speed
			xRate = MouseX.kr(1, 60)
				* (1 + (LFNoise1.kr(0.3) * 0.12));

			// each voice has a different excitation speed
			// with an additional ±40% wandering rate
			dustRate = xRate
				* [1.8, 2.2, 2.3, 3].choose
				* (1 + (LFNoise1.kr(0.15).range(-0.4, 0.4)));

			// Poisson-distributed stochastic excitation events
			dust = Dust.ar(dustRate);

			// Each event gets its own attack and decay.
			// 30% random deviation around the base times.
			env = Decay2.ar(
				dust,
				0.003 * TRand.kr(0.7, 1.3, dust),
				0.03 * TRand.kr(0.7, 1.3, dust)
			);

			// Pink noise excited by the randomized envelopes
			excitation = PinkNoise.ar * env;

			// independent slow random deviation for pitch randomness
			yPitch = MouseY.kr(2, 30)
				* (1 + (LFNoise1.kr(0.2) * 0.12));

			freq = Lag.kr(
				// use low freq step noise as a pitch control
				LFNoise0.kr(
					[1, 0.5, 0.25].choose,
					yPitch,
					66 + 30.rand2
				).round(0.4),
				0.2
			).midicps;

			// independent slow random deviation for CombL decay
			xCombDecay = MouseX.kr(1, 0.005)
				* (1 + (LFNoise1.kr(0.25) * 0.12));

			yDecay = MouseY.kr(0.2, 50)
				* (1 + (LFNoise1.kr(0.2) * 0.12));

			Pan2.ar(
				CombL.ar(
					excitation,
					0.02,
					freq.reciprocal,
					yDecay * xCombDecay
				),

				// each voice slowly wanders through the stereo field
				// movement gets faster as Mouse X moves right
				LFNoise1.kr(
					density.linlin(0.01, 1, 0.01, 0.08)
				)
			) * (i < voiceCount);
		})
	);

	// independent random deviation for reverb decay
	xReverbDecay = MouseX.kr(1, 0)
		* (1 + (LFNoise1.kr(0.2) * 0.12));

	// add some reverb via allpass delays
	// reverb decay gets extremely short toward the right
	5.do({
		signal = AllpassN.ar(
			signal,
			0.05,
			[0.05.rand, 0.05.rand],
			xReverbDecay.max(0)
		)
	});

	// delays build up a lot of DC, so leak it out here
	LeakDC.ar(signal, 0.995);
})
)



(
~quartet = NodeProxy.audio(s,2).play;
~quartet.fadeTime=1;
)


(
~quartet.source=
{	var amp, density, dmul, dadd, signal, xReverbDecay;
	var voiceCount, voiceChange;

	amp = 0.07;

	// Mouse X controls density.
	// Random deviation keeps the density from behaving mechanically.
	density = MouseX.kr(0.01, 1).pow(0.5)
		* (1 + (LFNoise1.kr(0.3) * 0.12));

	// calculate multiply and add for excitation probability
	dmul = density.reciprocal * 0.5 * amp;
	dadd = dmul.neg + amp;

	// Slowly choose a new number of active voices.
	// 30% = 1 voice
	// 20% = 2 voices
	// 20% = 3 voices
	// 30% = 4 voices
	voiceChange = Dust.kr(4.35);
	voiceCount = TWindex.kr(
		voiceChange,
		[0.3, 0.2, 0.2, 0.3]
	) + 1;

	signal = Mix.ar(
		// mix an array of 4 instruments
		Array.fill(4, { |i|
			var excitation, freq, dustRate, dust, env;
			var xRate, yPitch, yDecay, xCombDecay;

			// independent slow random deviation for X-controlled excitation speed
			xRate = MouseX.kr(1, 60)
				* (1 + (LFNoise1.kr(0.3) * 0.12));

			// each voice has a different excitation speed
			// with an additional ±40% wandering rate
			dustRate = xRate
				* [1.8, 2.2, 2.3, 3].choose
				* (1 + (LFNoise1.kr(0.15).range(-0.4, 0.4)));

			// Poisson-distributed stochastic excitation events
			dust = Dust.ar(dustRate);

			// Each event gets its own attack and decay.
			// 30% random deviation around the base times.
			env = Decay2.ar(
				dust,
				0.003 * TRand.kr(0.7, 1.3, dust),
				0.03 * TRand.kr(0.7, 1.3, dust)
			);

			// Pink noise excited by the randomized envelopes
			excitation = PinkNoise.ar * env;

			// independent slow random deviation for pitch randomness
			yPitch = MouseY.kr(2, 30)
				* (1 + (LFNoise1.kr(0.2) * 0.12));

			freq = Lag.kr(
				// use low freq step noise as a pitch control
				LFNoise0.kr(
					[1, 0.5, 0.25].choose,
					yPitch,
					66 + 30.rand2
				).round(0.4),
				0.2
			).midicps;

			// independent slow random deviation for CombL decay
			xCombDecay = MouseX.kr(1, 0.005)
				* (1 + (LFNoise1.kr(0.25) * 0.12));

			yDecay = MouseY.kr(0.2, 50)
				* (1 + (LFNoise1.kr(0.2) * 0.12));

			Pan2.ar(
				CombL.ar(
					excitation,
					0.02,
					freq.reciprocal,
					yDecay * xCombDecay
				),

				// each voice slowly wanders through the stereo field
				// movement gets faster as Mouse X moves right
				LFNoise1.kr(
					density.linlin(0.01, 1, 0.01, 0.08)
				)
			) * (i < voiceCount);
		})
	);

	// independent random deviation for reverb decay
	xReverbDecay = MouseX.kr(1, 0)
		* (1 + (LFNoise1.kr(0.2) * 0.12));

	// add some reverb via allpass delays
	// reverb decay gets extremely short toward the right
	10.do({
		signal = AllpassN.ar(
			signal,
			0.05,
			[0.05.rand, 0.05.rand],
			xReverbDecay.max(0)
		)
	});

	// delays build up a lot of DC, so leak it out here
	LeakDC.ar(signal, 0.995);
}
)



~quartet.source=nil