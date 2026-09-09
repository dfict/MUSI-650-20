//gotta make the crickets!

(
{
Pan2.ar(
	SinOsc.ar(rrand(52,108).midicps, 2pi.rand,
		Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0)
		* Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs
	), 1.0.rand2);

}.play;
)

//so inspired by Clint's "bird forest", we have a little generator here for a single cricket.
//how does it work?
// a sine wave at a random midi note, with a random phase, is being modulated by


(
{
var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,8) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(60,108).midicps, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
}.play;
)


(
~peepers = NodeProxy.audio(s, 2).play;
~peepers[0..10]= {
	arg max=8, pitch=200;
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,max) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(1,10)*pitch, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
};
)

~peepers[0..10]= nil

~peepers.gui