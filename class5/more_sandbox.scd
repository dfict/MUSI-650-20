{Mix.ar(SinOsc.ar([440,400,600,900,800])*0.1)}.play

{SinOsc.ar([440,400,600,800,900])*0.1}.play


{Mix.ar(SinOsc.ar(100*(5..8).asArray)*0.1)}.play


{(Mix.ar(SinOsc.ar(40+LFNoise1.ar(1!10).exprange(100,4000)))*0.1)!2}.play
{(Mix.ar(SinOsc.ar(40+LFNoise1.ar(0.01!20).exprange(100,4000)))*0.1)!2}.play
{(Mix.ar(SinOsc.ar(20+LFNoise1.ar(0.001!50).exprange(100,8000)))*0.05)!2}.play

{(Mix.ar(SinOsc.ar(50.midicps+LFNoise1.ar(0.001!20).exprange(44,110).midicps))*0.1)!2}.play


{ Mix.fill(12, { SinOsc.ar(30 + LFNoise1.kr(exprand(0.01,0.03)).range(10,3000))*0.1 }) }.play

{SinOsc.ar(40+LFNoise1.ar(1!10).exprange(100,4000))*0.1!2}.play

{
    var sig = SinOsc.ar(40 + LFNoise1.ar(1!4).exprange(100, 4000)) * 0.1;
    Out.ar([0, 1, 4, 5], sig);
}.scope;

s.meter;
Server.options
s.options.numOutputBusChannels = 2;

{ Mix(Ringz.ar(Dust.ar([1,2,2.4,0.1,0.4], 0.3), [1000,100,600,400,7000], 2) )!2}.play

{ Mix(Ringz.ar(Dust.ar(1!5, 0.3), [1000,100,600,400,7000], 2) )!2}.play



{
	Mix.fill(10, {
		Ringz.ar(Dust.ar(exprand(0.1, 2.4), 0.3), exprand(100, 7000), 2)
	})!2
}.play


({Mix.fill(3, {
		Ringz.ar(Dust.ar(exprand(0.1, 2), 0.3), exprand(100, 7000), 2)
})!2}.play)

{ Ringz.ar(Dust.ar(exprand(0.1,2)!3, 0.3), exprand(100,7000)!3, 2) }.play


(
{
    var phase = Phasor.ar(0, LFNoise0.kr(0.5!20).exprange(0.0004, 0.00125) * SampleDur.ir, 0, 2pi);
    var sig = 0.1 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
	sig>0.25;
}.scope;
)

{LFClipNoise.ar(TRand.ar(1,4,Impulse.ar(1))!3)}.scope


(SynthDef(\silence,
	{
	|rate = 2, max=0.125, amp=1|
	var out, mod;
		mod=LFNoise2.kr(rate!2).exprange(0.14, max);
		out = 99999999*LeakDC.ar(SinOsc.ar(mod)+SinOsc.ar(mod,pi));
	out=out*0.1*amp;
	Out.ar(0, out);
}).add;
)


a=(Synth(\silence));

a.set(\amp, 0.1);

a.set(\max, 40.4);
a.set(\rate, 0.2);

s.boot;

(
~drone = NodeProxy.audio(s, 2); // stereo audio proxy
~drone.fadeTime = 3; // all transitions crossfade over 3 seconds
)

// define/assign the source
(
~drone[0] = {
	LeakDC.ar(
		SinOsc.ar(LFNoise2.kr(1.5!2).exprange(0.14, 0.125))
		+ SinOsc.ar(LFNoise2.kr(1.5!2).exprange(0.14, 0.125), pi)
	) * 0.1
};
)


~drone.gui; // fades in over 3 seconds
~drone.stop; // fades out over 3 seconds

~drone.set