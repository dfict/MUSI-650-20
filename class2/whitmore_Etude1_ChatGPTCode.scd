(
// moto rev
{
	RLPF.ar(LFPulse.ar(SinOsc.kr(0.2, 0, 10, 21), 0.1), 100, 0.1).clip2(0.4)
}.play)

////////////////////////////////////////////////////////////////////////////
(
// moto rev - GLITCHED SAW
{
	var moto, saw, glitch, gate, freq;

	// ORIGINAL CODE
	moto = RLPF.ar(
		LFPulse.ar(
			SinOsc.kr(0.2, 0, 10, 21),
			0.1
		),
		100,
		0.1
	).clip2(0.4);

	// SAW VERSION
	freq = SinOsc.kr(0.2, 0, 10, 21);

	saw = Saw.ar(
		freq * [
			1,
			1.01,
			2
		]
	).sum * 0.2;

	// GLITCHY RANDOM GATING
	gate = LFPulse.kr(
		IRand(20, 80),
		0,
		TIRand.kr(0.1, 0.9)
	);

	// RANDOM SAMPLE-AND-HOLD PITCH GLITCHES
	saw = saw * (
		LFDNoise0.kr(35).range(0.05, 8)
	);

	// RANDOM FILTER MOVEMENT
	glitch = RLPF.ar(
		saw,
		LFDNoise0.kr(12).exprange(80, 8000),
		LFDNoise0.kr(7).range(0.02, 0.4)
	);


}.play
)

///////// as nodeProxy


(
~glitchyMoto = NodeProxy.new.play
)

(
~glitchyMoto[0] =
{
	arg tempo, lofreq, freq1, lofreq1, speed;
	var moto, saw, glitch, gate, freq;

	// ORIGINAL CODE
	moto = RLPF.ar(
		LFPulse.ar(
			SinOsc.kr(0.2, 0, 10, 21),
			0.1
		),
		100,
		0.1
	).clip2(0.4);

	// SAW VERSION
	freq = SinOsc.kr(lofreq1, 0, 10, 21);

	saw = Saw.ar(
		freq * [
			1,
			1.01,
			2
		]
	).sum * 0.2;

	// GLITCHY RANDOM GATING
	gate = LFPulse.kr(
		IRand(20, 80),
		0,
		TIRand.kr(0.1, 0.9)
	);

	// RANDOM SAMPLE-AND-HOLD PITCH GLITCHES
	saw = saw * (
		LFDNoise0.kr(35).range(0.05, 8)
	);

	// RANDOM FILTER MOVEMENT
	glitch = RLPF.ar(
		saw,
		LFDNoise0.kr(lofreq).exprange(80, 8000),
		LFDNoise0.kr(tempo).range(0.02, 0.4)
	);
}
)

Spec.add(\lofreq1, \lofreq);



//turn it back on
~glitchyMoto.gui
