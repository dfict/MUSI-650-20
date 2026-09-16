

//phase cancellation
{0.1*(SinOsc.ar(400)-SinOsc.ar(400))}.play;
{0.1*(SinOsc.ar(400)+SinOsc.ar(400,pi))}.play;

//phase with mouse control
{0.1*(SinOsc.ar(400)+SinOsc.ar(MouseX.kr(395,400),pi))}.play;
{0.1*(SinOsc.ar(400)-SinOsc.ar(MouseX.kr(395,400)))}.play;

//floating pt errors
{0.1*(99999999*LeakDC.ar(SinOsc.ar(0.1)+SinOsc.ar(0.1,pi)))}.play;

{0.1*Median.ar(30, Limiter.ar(99999999*LeakDC.ar((SinOsc.ar(0.005) + SinOsc.ar(0.005, pi)), 0.05)))!2}.play;


//floating point errors
//by Eli Rosenkim
//https://sccode.org/1-5g9

//SC-3 plugins needed...make sure you install
//github.com/supercollider/sc3-plugins


s.scope


//eli's original code
(
{ var pink;
	pink = PinkNoise.ar().range(0.08, 0.12)!2;
	0.5*LeakDC.ar(Median.ar(2, Limiter.ar(99999999*(SawDPW.ar(pink) + SawDPW.ar(pink, pi)), 0.9)))}.play;

{ var pink;
	pink = PinkNoise.ar().range(0.0999/3, 0.1001/3)!2;
	0.5*LeakDC.ar(Median.ar(5, Limiter.ar(99999999*(SawDPW.ar(pink) + SawDPW.ar(pink, pi)), 0.9)))}.play;

{var pink;
	pink = PinkNoise.ar().range(0.00999, 0.01001)!2;
	(0.5*Median.ar(20,
	Limiter.ar(999999*LeakDC.ar(SawDPW.ar(pink, 0+(pi/2)) + SawDPW.ar(pink, pi+(pi/2))), 0.1)))}.play;


{0.5*Median.ar(30, Limiter.ar(99999999*LeakDC.ar((SinOsc.ar(0.005) + SinOsc.ar(0.005, pi)), 0.05)))!2}.play; //here's the cool one!

{0.5*SVF.ar((Median.ar(10, Limiter.ar(999999*LeakDC.ar(LFPulse.ar(0.5) + LFPulse.ar(0.5, pi)), 0.6))), 800)!2}.play;

)

//silent sine nodeproxy with pitch control
//what does median do?
(
s.boot;

Spec.add(\period, ControlSpec(0.01, 10, 'exp', 0, 0.005));
~silentSine = NodeProxy.new.play;
~silentSine.source = {|period=0.005|
	0.1*Median.ar(30, Limiter.ar(99999999*LeakDC.ar((SinOsc.ar(period/10) + SinOsc.ar(period/10, pi)), 0.05)))!2};


//"silent"" SVF isn't actually so silent. not sure if it's "silent" at all, but it provides a nice rhythm.

Spec.add(\rhythm, ControlSpec(0.01, 10, 'exp', 0, 0.5));
~essV = NodeProxy.new.play;
~essV.source = {|rhythm=0.5|
	0.1*SVF.ar((Median.ar(1, Limiter.ar(99999999*LeakDC.ar(LFPulse.ar(rhythm/1) + LFPulse.ar(rhythm/1, pi)), 0.6))), 800)!2};


//adding a pink noise instrument

Spec.add(\pinkRate, ControlSpec(0.0499, 0.2001, 'lin', 0, 0.5));
~pink1 = NodeProxy.new.play;
~pink1.source =
{ |lofreq=3, pinkRate=0.1001|
	var pink;
	pink = PinkNoise.ar().range(0.0999/lofreq, 0.1001/lofreq)!2;
	0.5*LeakDC.ar(Median.ar(5, Limiter.ar(99999999*(SawDPW.ar(pink) + SawDPW.ar(pink, pi)), 0.9)))
};


// another pink instrument
Spec.add(\pink2Rate, ControlSpec(0.0499, 180.2001, 'lin', 0, 0.5));
~pink2 = NodeProxy.new.play;
~pink2.source =
{ |lofreq=3, pink2Rate=0.1001|
	var pink, out;
//	pink = PinkNoise.ar().range(0.0999/lofreq, 0.1001/lofreq)!2;
	pink= LFNoise1.ar(lofreq!2).exprange(pink2Rate);
	out= 0.5*LeakDC.ar(Median.ar(5, Limiter.ar(99999999*(SawDPW.ar(pink) + SawDPW.ar(pink, pi)), 0.9)));
	// 1) Compander: duck gain hard for the instant a click is detected
	out = Median.ar(20, out); // catch most impulses structurally
	detect = abs(HPZ1.ar(HPZ1.ar(out)));
	out = Compander.ar(out, detect, 0.01, 1, 0, 0.00002, 0.003);
};
~pink2.gui



//set up the templates
s.scope
p = ~pink1.gui;
p.parent.alwaysOnTop_(true);
p.parent.bounds_(Rect(900, 300, 400, 200)); // x, y, width, height

g = ~essV.gui;
g.parent.alwaysOnTop_(true);
g.parent.bounds_(Rect(900, 50, 400, 200));


w = ~silentSine.gui;
w.parent.alwaysOnTop_(true);
w.parent.bounds_(Rect(900, 570, 400, 200));
)

//better implemented
~silentSine.source = {|period=0.005|
	var out, mod;
	mod=period;
	mod = LFNoise1.kr(period!2).exprange(0.01, 10.125);
	out = Median.ar(30, Limiter.ar(99999999*LeakDC.ar((SinOsc.ar(mod) + SinOsc.ar(mod, pi)), 0.05)));
	out=0.5*out;
	out;
};



//sandbox
//
{0.1*(99999999*LeakDC.ar(SinOsc.ar(0.1)+SinOsc.ar(0.1,pi)))}.play;



({
	var mod = MouseX.kr(0.01,30,1);
	mod.poll(10.02, "mod");
	0.1*(99999999*LeakDC.ar(SinOsc.ar(mod)+SinOsc.ar(mod,pi)))}.play;)


({
	var mod = LFNoise1.kr(1.5!2).exprange(0.14, 1.125);
	0.05*(99999999*LeakDC.ar(SinOsc.ar(mod)+SinOsc.ar(mod,pi)))}.play;)
s.scope

{0.1*(99999999*LeakDC.ar(SinOsc.ar(0.1)+SinOsc.ar(0.1,pi)))}.play;

(a={
	arg rate, out;
	rate=110.1;
	rate=LFNoise2.kr(1.5!2).exprange(0.14, 10.125);
	out=99999999*LeakDC.ar(SinOsc.ar(rate)+SinOsc.ar(rate,pi));
	out=out*0.1;}.scope;)
a.scope

(
{
    var phase = Phasor.ar(0, 0.1 * SampleDur.ir, 0, 2pi);
    0.1 * (99999999*LeakDC.ar(cos(phase) + cos(phase + pi)));
}.play;
)


(
{
    var phase = Phasor.ar(0, LFNoise2.kr(0.5!2).exprange(0.04, 0.125) * SampleDur.ir, 0, 2pi);
    0.01 * (99999999*LeakDC.ar(cos(phase) + cos(phase + pi)));
}.play;
)

(
{
    var phase = Phasor.ar(0, LFNoise2.kr(0.5!2).exprange(0.04, 0.125) * SampleDur.ir, 0, 2pi);
	0.01 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
}.play;
)

s.scope
(
{
    var phase = Phasor.ar(0, LFNoise0.kr(0.5!2).exprange(0.0004, 0.00125) * SampleDur.ir, 0, 2pi);
	0.01 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
}.play;
)

(
{
    var phase = Phasor.ar(0, LFNoise0.kr(0.5!2).exprange(0.0004, 0.00125) * SampleDur.ir, 0, 2pi);
    var sig = 0.1 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
	sig>0.25;
}.play;
)

s.scope

(
{
    var phase = Phasor.ar(0, LFNoise0.kr(0.5!2).exprange(0.0004, 0.00125) * SampleDur.ir, 0, 2pi);
    var sig = 0.1 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
    HPZ1.ar(sig);
}.play;
)


(
~phasorCreep = NodeProxy.new.play;
~phasorCreep[0]=
{|lofreq=0.5, amp=1|
    var phase = Phasor.ar(0, LFNoise0.kr(lofreq!2).exprange(0.0004, 0.00125) * SampleDur.ir, 0, 2pi);
    var sig = 0.1 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
	sig>MouseX.kr(0,1);
	sig * amp;
};
~phasorCreep.gui)
~phasorCreep.gui

~phasorCreep.set(\lofreq, 100)
~phasorCreep.set(\amp, 0)


~phasorCreep[0] = {|lofreq=0.5, amp=1|
    var laggedAmp = Lag.kr(amp, 20); // 5 second smoothing time
    var phase = Phasor.ar(0, LFNoise0.kr(lofreq!2).exprange(0.0004, 0.00125) * SampleDur.ir, 0, 2pi);
    var sig = 0.1 * (99999999*LeakDC.ar(Median.ar(25,cos(phase) + cos(phase + pi))));
	sig = sig * MouseX.kr(0,1);
	sig * laggedAmp;
};

~phasorCreep.set(\amp, 0);
~phasorCreep.set(\amp, 1); // now glides smoothly over 5 seconds, no Routine needed


(Spec.add(\pink2Rate, ControlSpec(0.0499, 180.2001, 'lin', 0, 0.5));
Spec.add(\medianWin, ControlSpec(1, 31, 1, 2, 5));
Spec.add(\compThresh, ControlSpec(0.0001, 1, 'exp', 0, 0.01));
Spec.add(\compSlopeBelow, ControlSpec(0.01, 4, 'exp', 0, 1));
Spec.add(\compSlopeAbove, ControlSpec(0.0, 1, 'lin', 0, 0));
Spec.add(\compClampTime, ControlSpec(0.00001, 0.02, 'exp', 0, 0.00002));
Spec.add(\compRelaxTime, ControlSpec(0.0001, 0.5, 'exp', 0, 0.003));)

(~pink2.source =
{ |lofreq=3, pink2Rate=0.1001,
	compThresh=0.01, compSlopeBelow=1, compSlopeAbove=0,
	compClampTime=0.00002, compRelaxTime=0.003, medianWin=5|

	var pink, out, detect;

	pink = LFNoise1.ar(lofreq!2).exprange(pink2Rate);
	out = 0.5*LeakDC.ar(Median.ar(5, Limiter.ar(99999999*(SawDPW.ar(pink) + SawDPW.ar(pink, pi)), 0.9)));
	out = Median.ar(medianWin.round(2).max(1), out);

	detect = abs(HPZ1.ar(HPZ1.ar(out)));

	out = Compander.ar(
		out, detect,
		compThresh,
		compSlopeBelow,
		compSlopeAbove,
		compClampTime,
		compRelaxTime
	);
};)


~pink2.gui;

(~pink2.source =
{ |lofreq=3, pink2Rate=0.01001,
	compThresh=0.01, compSlopeBelow=1, compSlopeAbove=0,
	compClampTime=0.00002, compRelaxTime=0.003, medianWin=5|

	var pink, out, detect, a, b;

	pink = LFNoise1.ar(lofreq!2).exprange(pink2Rate);
	a = SawDPW.ar(pink);
	b = LeakDC.ar(Integrator.ar(HPZ1.ar(SawDPW.ar(pink)) - 0, 0.999)); // contrived alt path, same nominal signal
		out=LeakDC.ar(Limiter.ar(999999999*(a + b), 0.9));
	out = Median.ar(medianWin.round(2).max(1), out);
	detect = abs(HPZ1.ar(HPZ1.ar(out)));

	out = Compander.ar(
		out, detect,
		compThresh,
		compSlopeBelow,
		compSlopeAbove,
		compClampTime,
		compRelaxTime
	);
};
)
~pink2.gui

s.scope



//finally a new one!
(b={ var pink, a, b, out;
	pink = PinkNoise.ar().range(0.08/4, 0.012/4)!2;
	pink=LFNoise1.ar(0.5!2).range(0.08/4, 0.012/4);
	pink=LFNoise1.ar(0.5!2).range(0.08/4, 0.012/4)+PinkNoise.ar().range(0.08/4, 0.112/4);
	a = SawDPW.ar(pink);
	b = LeakDC.ar(Integrator.ar(HPZ1.ar(SawDPW.ar(pink)) - 0, 0.999)); // contrived alt path, same nominal signal
	out=LeakDC.ar(Limiter.ar(999999999*(a + b), 0.9));
	//out=Median.ar(5,out,0.9);
	out=out*0.5;
}.play;)

//and another!
(a={
	var out, time;
	time=0.0001;
	time=0.01;
	time=LFNoise1.ar(1!2).range(0.0001,0.002);
	time=LFNoise1.ar(0.001!2).range(0.0001,0.005);
	out=(99999999*LeakDC.ar(SinOsc.ar(time)+SinOsc.ar(time,2pi/3)+SinOsc.ar(time,4pi/3)));
	out*0.1;
}.play;)



//NEW MATERIAL..

//nice piece!
(
{ var engine, core, a, b, out;
	engine = LFNoise1.ar(1).range(0.0001,0.02001);//hmm
	core=LFNoise0.ar(2, 0.5, LFTri.ar(LFNoise1.kr(engine!2))).range(0.08/4, 0.012/4) + PinkNoise.ar(0.01, 1).range(0.08/4, 0.012/4);
	a = LeakDC.ar(SawDPW.ar(core), 0.995, 0.5) + SawDPW.ar(core, 0.995, 0.5);
    b = LeakDC.ar(Integrator.ar(HPZ1.ar(SawDPW.ar(core)) - 0, 0.9999)); // contrived alt path, same nominal signal
    out=LeakDC.ar(Limiter.ar(999999*(a + b), 0.9));
    out=Median.ar(5,out,0.9);
    out=out*0.5;
 }.play;)

//compare to this one....
{var c=LFNoise0.ar(2,0.5,LFTri.ar(LFNoise1.kr(LFNoise1.ar(1).range(1e-4,1.001)!2))).range(0.02,0.003)+PinkNoise.ar(0.01,1).range(0.02,0.003);Median.ar(5,LeakDC.ar(Limiter.ar(1e6*(LeakDC.ar(SawDPW.ar(c),0.995,0.5)+SawDPW.ar(c,0.995,0.5)),0.9)),0.9)*0.5}.play

{var c=LFNoise0.ar(2,0.5,LFTri.ar(LFNoise1.kr(LFNoise1.ar(1).range(1e-4,1.001)!2))).range(0.02,0.003)+PinkNoise.ar(0.01,1).range(0.02,0.003),s=SawDPW.ar(c);Median.ar(5,LeakDC.ar(Limiter.ar(1e6*(LeakDC.ar(s,0.995,0.5)+SawDPW.ar(c,0.995,0.5)+LeakDC.ar(Integrator.ar(HPZ1.ar(s),0.9999))),0.9)),0.9)*0.5}.play

({ var pink, a, b, out;
	pink=LFNoise0.ar(2!2, 0.5, LFTri.ar(LFNoise1.kr(0.01))).range(0.08/4, 0.012/4) + PinkNoise.ar(0.01, 1).range(0.08/4, 0.012/4);
	a = LeakDC.ar(SawDPW.ar(pink), 0.995, 0.5) + SawDPW.ar(pink, 0.995, 0.5);
    b = LeakDC.ar(Integrator.ar(HPZ1.ar(SawDPW.ar(pink)) - 0, 0.9999)); // contrived alt path, same nominal signal
    out=LeakDC.ar(Limiter.ar(999999*(a + b), 0.9));
    out=Median.ar(5,out,0.9);
    out=out*0.5;
}.play;)

//nice piece
({ var pink, a, b, out;
	pink=LFNoise0.ar(2.2!2, 0.5, LFNoise0.kr(1.01)).range(0.08/4, 0.012/4) + SinOsc.ar(10.1) + PinkNoise.ar(0.01, 1).range(0.08/4, 0.012/4);
	a = LeakDC.ar(SawDPW.ar(pink), 0.995, 0.5) + SawDPW.ar(pink, 0.995, 0.5);
    b = LeakDC.ar(Integrator.ar(HPZ1.ar(SawDPW.ar(pink)) - 0, 0.9999)); // contrived alt path, same nominal signal
    out=LeakDC.ar(Limiter.ar(999999*(a + b), 0.9));
    out=Median.ar(5,out,0.9);
    out=out*0.5;
}.play;)

//nice piece also.
({ var pink, a, b, out;
	pink=LFNoise0.ar(2.2, 0.5, LFNoise1.kr(1.01!2)).range(0.08/4, 0.012/4) + SinOsc.ar(10.1) + PinkNoise.ar(0.01, 1).range(0.08/4, 0.012/4);
	a = LeakDC.ar(SawDPW.ar(pink), 0.995, 0.5) + SawDPW.ar(pink, 0.995, 0.5);
    b = LeakDC.ar(Integrator.ar(HPZ1.ar(SawDPW.ar(pink)) - 0, 0.9999)); // contrived alt path, same nominal signal
    out=LeakDC.ar(Limiter.ar(999999*(a + b), 0.9));
    out=Median.ar(5,out,0.9);
    out=out*0.5;
}.play;)

({ var pink, a, b, out;
	pink=LFNoise0.ar(2.2, 0.5, LFTri.ar(LFNoise1.kr(1.01!2)).range(0.08/4, 0.012/4)) + SinOsc.ar(10.1) + PinkNoise.ar(0.01, 1).range(0.08/4, 0.012/4);
	a = LeakDC.ar(SawDPW.ar(pink), 0.995, 0.5) + SawDPW.ar(pink, 0.995, 0.5);
    b = LeakDC.ar(Integrator.ar(HPZ1.ar(SawDPW.ar(pink)) - 0, 0.9999)); // contrived alt path, same nominal signal
    out=LeakDC.ar(Limiter.ar(999999*(a + b), 0.9));
    out=Median.ar(5,out,0.9);
    out=out*0.5;
}.play;)


({ var pink, a, b, out;
	pink=LFNoise0.ar(2, 0.5, LFTri.ar(LFNoise1.kr(1!2)).range(0.08/4, 0.012/4)) + PinkNoise.ar(0.01, 1).range(0.08/4, 0.012/4);
	a = LeakDC.ar(SawDPW.ar(pink), 0.995, 0.5) + SawDPW.ar(pink, 0.995, 0.5);
    b = LeakDC.ar(Integrator.ar(HPZ1.ar(SawDPW.ar(pink)) - 0, 0.9999)); // contrived alt path, same nominal signal
    out=LeakDC.ar(Limiter.ar(999999*(a + b), 0.9));
    out=Median.ar(5,out,0.9);
    out=out*0.5;
}.play;)


(
{ var engine, core, a, b, out;
	engine = LFNoise1.ar(1).range(0.0001,1.001);
	core=Mix.fill(8,LFNoise0.ar(2, 0.5, LFTri.ar(LFNoise1.kr(engine!2))).range(0.08/4, 0.012/4) + PinkNoise.ar(0.01, 1).range(0.08/4, 0.012/4));
	a = LeakDC.ar(SawDPW.ar(core), 0.995, 0.5) + SawDPW.ar(core, 0.995, 0.5);
    b = LeakDC.ar(Integrator.ar(HPZ1.ar(SawDPW.ar(core)) - 0, 0.9999)); // contrived alt path, same nominal signal
    out=LeakDC.ar(Limiter.ar(999999*(a + b), 0.9));
    out=Median.ar(5,out,0.9);
    out=out*0.5;
}.play;)
