//Modified Code//
(
// LFO modulation of Pulse waves and resonant filters
 play({
	var sig, tremolo;
	sig = CombL.ar(
		RLPF.ar(LFPulse.ar(FSinOsc.kr(0.05,0,80,160),0,0.4,0.05),
		   LFSaw.kr(0.1).exprange(500, 12000), 0.2),
		0.3, [0.2,0.75], 2);
	tremolo = SinOsc.kr(95/60 * 2).range(0.4, 1);
	sig = sig * tremolo;
}))


//Original Code//
(
// LFO modulation of Pulse waves and resonant filters
play({
	CombL.ar(
		RLPF.ar(LFPulse.ar(FSinOsc.kr(0.05,0,80,160),0,0.4,0.05),
		   FSinOsc.kr([0.6,0.7],0,3600,4000), 0.2),
		0.3, [0.2,0.25], 2)
}))


//NodeProxy Version

(
~coolLFO = NodeProxy.new.play;
// LFO modulation of Pulse waves and resonant filters
~coolLFO[0]=
{
	|lofreq=1.5, lofreq1=0.1|
	var sig, tremolo;
	sig = CombL.ar(
		RLPF.ar(LFPulse.ar(FSinOsc.kr(0.05,0,80,160),0,0.4,0.05),
		   LFSaw.kr(lofreq1).exprange(500, 12000), 0.2),
		0.3, [0.2,0.75], 2);
	tremolo = SinOsc.kr(lofreq * 2).range(0.4, 1);
	sig = sig * tremolo;
})

~coolLFO.gui