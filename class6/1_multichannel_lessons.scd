//try starting out by running this code...

(
s.options.numOutputBusChannels = 12;  // match your interface
s.options.numInputBusChannels = 12;   // optional, if you need inputs too
// s.options.outDevice = "Your Interface Name";  // if it isn't the default device
s.reboot;
)


//you need to tell supercollider to reconfigure the server and its outputs to have however many inputs and outputs you need.
//this block of code configures up to 12 inputs and outputs and the rest of the code will now work accordingly.

{Mix.ar(SinOsc.ar([440,400,600,900,800])*0.1)}.play

//so this block of code plays the six frequencies you code in the array, but since its wrapped in a Mix UGen, it is in mono.

{SinOsc.ar([440,400,600,900,800])*0.1}.play

//this prints the array to all separate channels. 5 channels to be precise. look with the scope method to be sure!


{Mix.ar(SinOsc.ar([100, 150, 440,400,600,900,800, 950, 1075,1200 ])*0.1)}.play
//this is in mono.

{(SinOsc.ar([100, 150, 440,400,600,900,800, 950, 1075,1200 ])*0.1)}.scope
//this is in 10 channels.





//let's put some random frequencies in our chord

//here's a kind of clunky way to do it, because the array has to be manually expanded.

(w = {var pitch = exprand(70, 4000);
	SinOsc.ar([(rand(200,300)), (exprand(200,300)), 400, 600])*0.5}.scope)

//so here's a more efficient way to do it, using the Array class, which we haven't discussed, but is super powerful.
(w = {var pitch = exprand(70, 4000);
	SinOsc.ar(Array.exprand(10, 100, 3000).round)*0.1}.scope)

//alternative...in mono

(w = {var pitch = exprand(70, 4000);
	Mix.new(SinOsc.ar(Array.exprand(5, 40, 3000))*0.1)}.scope)

//array can be used with the .fill method
Array.fill(10, "hello".postln)
//which takes a size, and a function as its arguments.


//whereas this mixes all twelve channels down to mono
{ Mix.fill(12, { SinOsc.ar(30 + LFNoise1.kr(exprand(0.01,0.03)).range(10,3000))*0.1 }) }.scope

//Array.fill says, take this array and iterate it ten times.
{ Array.fill(12, { SinOsc.ar(30 + LFNoise1.kr(exprand(0.01,0.03)).range(10,3000))*0.1 }) }.scope






//Remember, all we are doing here is creating different arrays.

// let's take this synthesis function are work through it.

(
{
    var sig, mod;
	sig = SinOsc.ar(100+(LFNoise1.kr({exprand(0.1,1)}).range(200,1000)));
	mod = {SinOsc.kr(exprand(0.1,12)).range(0,1)};
    sig = sig * mod;
    sig = sig * 0.2;
	sig!10;
}.scope;
)

//now we get different frequencies because of WHERE we told the Server to expand the array.
(
{
    var sig, mod;
	sig = SinOsc.ar(100+(LFNoise1.kr({exprand(0.1,1)}!10).range(200,1000)));
	mod = {SinOsc.kr(exprand(0.1,12)).range(0,1)};
    sig = sig * mod;
    sig = sig * 0.2;
}.scope;
)

//can you improve this to also have rhythm articulates across the array?


//again, where you duplicate matters.
{SinOsc.ar(LFNoise0.kr(1).range(200, 1000).dup(10))}.scope

//can you fix it so it iterates multiple patterns?


//better
{SinOsc.ar(LFNoise1.kr(1.dup(10)).range(200, 1000))*SinOsc.ar(LFNoise1.ar(4!10).range(0,1))}.scope



///using specific multichannel pan ugens...

//try this lovely panner
//PanAz's pos isn't measured in channels, but from 0 to 2. A value of 2 is one full trip around all the speakers.
(
~n = 10;  // number of output channels
{
    var pos = MouseX.kr(0, 2 * (~n - 1) / ~n, lag: 0.1);
    PanAz.ar(~n, WhiteNoise.ar(0.1), pos, orientation: 0);
}.scope;
)

(
~n = 10;
{
    var chan = LFNoise1.kr(0.1).range(0, ~n - 1);  // 0..9, in channel units
    var pos = chan * 2 / ~n;                         // convert to PanAz units
    PanAz.ar(~n, WhiteNoise.ar(0.1), pos, orientation: 0);
}.scope;
)



//where you put the dup (the array expansion matters)
{SinOsc.ar(200+LFNoise1.kr(0.01!10).exprange(10,2000))*LFTri.kr(0.1.rand).dup(10)}.scope

{SinOsc.ar(200+LFNoise1.kr(0.01!10).exprange(10,2000))*{LFTri.kr(0.1.rand)}.dup(10)}.scope

//adding a new function allows each evaluation of LFNoise to be unique.
{SinOsc.ar(200 + {LFNoise1.kr(0.1.rand)}.dup(10).exprange(10, 2000))}.scope


// One LFO — all 10 oscillators pulse in sync
{SinOsc.ar((1..10) * 200) * LFNoise1.kr(1).range(0, 1)}.scope

// Ten independent LFOs — each oscillator pulses at its own rate
{SinOsc.ar((1..10) * 2000.rand) * {LFNoise1.kr(10.rand)}.dup(10).range(0, 1)}.scope


//the following examples are mixed to mono or stereo, can you re-program them so they play in ten channels?


{(Mix.ar(SinOsc.ar(40+LFNoise1.ar(1!10).exprange(100,4000)))*0.1)!2}.play
{(Mix.ar(SinOsc.ar(40+LFNoise1.ar(0.01!20).exprange(100,4000)))*0.1)!2}.play
{(Mix.ar(SinOsc.ar(20+LFNoise1.ar(0.001!50).exprange(100,8000)))*0.05)!2}.scope

{(Mix.ar(SinOsc.ar(50.midicps+LFNoise1.ar(0.001!20).exprange(44,110).midicps))*0.1)!2}.play


{ Mix.fill(12, { SinOsc.ar(30 + LFNoise1.kr(exprand(0.01,0.03)).range(10,3000))*0.1 }) }.scope

{SinOsc.ar(40+LFNoise1.ar(1!10).exprange(100,4000))*0.1!2}.play


{
	Mix.fill(10, {
		Ringz.ar(Dust.ar(exprand(0.1, 2.4), 0.3), exprand(100, 7000), 2)
	})!2
}.play



// here's that lovely "silent" synthezer
(
{
    var phase = Phasor.ar(0, LFNoise0.kr(0.5!12).exprange(0.0004, 0.00125) * SampleDur.ir, 0, 2pi);
    var sig = 0.1 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
	sig>0.25;
}.scope;
)
//


//adding a new function around LFNoise allows for unique evaluation of each random rate
(
{
    var phase = Phasor.ar(0, {LFNoise0.kr(0.5.rand).exprange(0.0004, 0.00125)}!10 * SampleDur.ir, 0, 2pi);
    var sig = 0.1 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
	sig>0.25;
}.scope;
)

//this is going to be batshit insane!
(
{
	var window = MouseX.kr(0.01, 0.5);
	var max = MouseY.kr(0.00125, 0.125);
    var phase = Phasor.ar(0, {LFNoise0.kr(0.5.rand).exprange(0.0004, max)}!10 * SampleDur.ir, 0, 2pi);
    var sig = 0.1 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
	sig>window;
}.scope;
)


(
~n = 10;       // output channels
~voices = 1;   // how many resonators

{
    var sigs = Array.fill(~voices, {
        Ringz.ar(Dust.ar(exprand(0.1, 2.4), 0.3), exprand(100, 7000), 2)
    });
    var pos = Array.fill(~voices, {
        LFNoise1.kr(0.5).range(0, ~n - 1) * 2 / ~n   // channel units → PanAz units
    });

    PanAz.ar(~n, sigs, pos, orientation: 0).sum;
}.play;
)
