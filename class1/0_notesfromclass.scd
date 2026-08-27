// hello world
(
Server.default.boot;
Date.getDate;
)

/*means anything inside the comment will not be evaluated as code*/
this is a comment

Date.getDate.format("Today is %A. It is around %I o'clock (%p), in %B.");

s.boot;

(midinote:[80,60,55]).play

{PinkNoise.ar(SinOsc.ar(MouseY.kr(1,25),0.1))}.play
//.....figure out how to send this sound through a filter and control the filter cutoff with MouseX

//use...
{RLPF.ar(PinkNoise.ar(SinOsc.ar(MouseY.kr(1,25),0.1)),SinOsc.ar(MouseX.kr(1,10)).range(100,3000),0.4)}.play

{SinOsc.ar(MouseY.kr(200,4000),0,MouseX.kr(0.0,0.7))!2}.scope

(
t=
{
var volume, pitch, sound, silly;
	pitch = MouseX.kr(100,2000);
	volume = MouseY.kr(1,2);
	silly = LFTri.ar(volume);
	sound = LFSaw.ar(pitch, 0, silly);
	sound * 0.1;
}
)

x=t.scope
x.free