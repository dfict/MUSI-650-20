

{(SinOsc.ar(441) + SinOsc.ar(-441))}.plot;

//phase cancellation
{0.1*(SinOsc.ar(400)-SinOsc.ar(400))}.play;
{0.1*(SinOsc.ar(400)+SinOsc.ar(400,pi))}.play;

//phase with mouse control
{0.1*(SinOsc.ar(400)+SinOsc.ar(MouseX.kr(395,400),pi))}.play;
{0.1*(SinOsc.ar(400)-SinOsc.ar(MouseX.kr(395,400)))}.play;

//floating pt errors
{0.1*(99999999*LeakDC.ar(SinOsc.ar(0.1)+SinOsc.ar(0.1,pi)))}.play;

{0.1*Median.ar(30, Limiter.ar(99999999*LeakDC.ar((SinOsc.ar(0.005) + SinOsc.ar(0.005, pi)), 0.05)))!2}.play;


// use plot so you don't need the whole scaling routine!
//These show differing rounding errors:
{(SinOsc.ar(441) + SinOsc.ar(-441))}.plot;

{(SinOsc.ar(440) + SinOsc.ar(-440))}.plot;
{(SinOsc.ar(480) + SinOsc.ar(-480))}.plot;

//This doesn't:
{var p = LFSaw.ar(441).range(0, 2pi); sin(p)  + sin(p * -1)  }.plot

//so, these are artifacts of the UGen implementation.


