(
{
    var sig, mod;
    sig = SinOsc.ar((1..10).asArray * 450);
    mod = SinOsc.kr((1..10).asArray).range(0, 1);
    sig = sig * mod;
    sig = sig * 0.2;
}.scope;
)
Multichannel Arrays for multichannel stuff

(
{
    var sig, mod, freqs;
    freqs = Array.rand(10, 200, 1000); // 10 random floats between 200 and 1000
	sig = SinOsc.ar(freqs);
    mod = SinOsc.kr(Array.rand(10, 0.1, 12)).range(0, 1);
    sig = sig * mod;
    sig = sig * 0.2;
}.scope;
)

(
{
    var sig, mod, freqs;
    freqs = Array.rand(10, 200, 1000); // 10 random floats between 200 and 1000
	sig = SinOsc.ar(freqs+(LFNoise1.kr(freqs).range(5,50)));
    mod = SinOsc.kr(Array.rand(10, 0.1, 12)).range(0, 1);
    sig = sig * mod;
    sig = sig * 0.2;
}.scope;
)


(
{
    var sig, mod, freqs;
	sig = SinOsc.ar(100+(LFNoise1.kr(0.1!10).range(200,2000)));
    mod = SinOsc.kr(Array.rand(10, 0.1, 12)).range(0, 1);
    sig = sig * mod;
    sig = sig * 0.2;
}.scope;
)

(
{
    var sig, mod;
	sig = SinOsc.ar(100+(LFNoise1.kr({exprand(0.1,1)}!10).range(200,1000)));
	mod = {SinOsc.kr(exprand(0.1,12)).range(0,1)}!10;
    sig = sig * mod;
    sig = sig * 0.2;
}.scope;
)

(
{
    var sig, mod, freqs;
    freqs = Array.rand(10, 200, 1000); // 10 random floats between 200 and 1000
	sig = SinOsc.ar(LFNoise1.kr(0.1).range(200, 1000).dup(10));
    mod = SinOsc.kr(Array.rand(10, 0.1, 12)).range(0, 1);
    sig = sig * mod;
    sig = sig * 0.2;
}.scope;
)

{SinOsc.ar(LFNoise0.kr(1).range(200.rand, 1000.rand).dup(10))}.scope
{SinOsc.ar(LFNoise0.kr(1).range(200, 1000).dup(10))}.scope //WHERE you duplicate maters


(
{
    var phase = Phasor.ar(0, LFNoise0.kr(0.5!10).exprange(0.0004, 0.00125) * SampleDur.ir, 0, 2pi);
    var sig = 0.1 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
	sig>0.25;
}.scope;
)

//where you put the dup (the array expansion matters)
{SinOsc.ar(200+LFNoise1.kr(0.01!10).exprange(10,2000))*LFTri.kr(0.1.rand).dup(10)}.scope

{SinOsc.ar(200+LFNoise1.kr(0.01!10).exprange(10,2000))*{LFTri.kr(0.1.rand)}.dup(10)}.scope

//adding a new function allows each evaluation of LFNoise to be unique.
{SinOsc.ar(200 + {LFNoise1.kr(0.1.rand)}.dup(10).exprange(10, 2000))}.scope



{SinOsc.ar((1..60)*200)}.freqscope

//adding a new function around LFNoise allows for unique evaluation of each random rate
(
{
    var phase = Phasor.ar(0, {LFNoise0.kr(0.5.rand).exprange(0.0004, 0.00125)}!10 * SampleDur.ir, 0, 2pi);
    var sig = 0.1 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
	sig>0.25;
}.scope;
)

(
{
	var window = MouseX.kr(0.01, 0.5);
	var max = MouseY.kr(0.00125, 0.125);
    var phase = Phasor.ar(0, {LFNoise0.kr(0.5.rand).exprange(0.0004, max)}!10 * SampleDur.ir, 0, 2pi);
    var sig = 0.1 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
	sig>window;
}.scope;
)

// One LFO — all 10 oscillators pulse in sync
{SinOsc.ar((1..10) * 200) * LFNoise1.kr(1).range(0, 1)}.scope

// Ten independent LFOs — each oscillator pulses at its own rate
{SinOsc.ar((1..10) * 2000.rand) * {LFNoise1.kr(10.rand)}.dup(10).range(0, 1)}.scope