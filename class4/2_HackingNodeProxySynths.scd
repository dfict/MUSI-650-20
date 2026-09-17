//in this example we will start working with my most recent favorite NodeProxy instrument



//we have a lovely example we want to modify to play samples.

(
s.waitForBoot({
~twine = NodeProxy.audio(s, 2);
~twine[0..6] = { |widefreq = 4.25, lo = 4, hi = 5, attack = 0.1, decay = 0.1 |
	var aud, f;
	lo = lo * exprand(1, 200);
	hi = hi * exprand(1, 200);
	f = LFClipNoise.kr(widefreq*rrand(0.1, 4.0)).range(lo, hi);
	aud = SinOsc.ar(f) * 0.1;
	aud = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * aud;
	aud.dup;
};

~twine.play;
w = ~twine.gui;
w.parent.alwaysOnTop_(true); //slams the server window on top of the Interpreter.
}))

~twine[0..8]=nil;

~twine.removeLast//the undo button
~twine.source=nil  //kill
~twine.gui //look


~twineSample = NodeProxy.audio(s, 2).play; //new node!

(
~buf = Buffer.read(s, "audio/xlyobpari.wav".resolveRelative); //resolveRelative finds the file in the same dir as this file
)

(
~buf = Buffer.read(s, "audio/daxCHORD.wav".resolveRelative); //resolveRelative finds the file in the same dir as this file
)

(
~twineSample[0..8] = { |widefreq = 4.25, lo = 4, hi = 5, attack = 0.1, decay = 0.1 |
    var aud, fee;
    lo = lo * exprand(1, 200);
    hi = hi * exprand(1, 200);

    // Instead of direct frequency modulation, we'll use rate multiplication
    fee = LFClipNoise.kr(widefreq * rrand(0.1, 4.0)).range(lo/440, hi/440);

    // PlayBuf replaces SinOsc
    aud = PlayBuf.ar(
        numChannels: ~buf.numChannels,
        bufnum: ~buf,
        rate: fee * BufRateScale.kr(~buf), //bingo!
        loop: 1
    ) * 0.1;

    // Keep the amplitude envelope
    aud = Linen.kr(abs(Slope.kr(fee)), attack, 1, decay) * aud;
    aud.dup;
};
)
~twineSample.gui


~twineSample[4..10]=nil

~buf.zero
~buf.read("/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/skeleton_bones.wav")
~buf.read("/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxCHORD.wav")
~buf.read("/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/daxKICK_2.wav")

(
~twineSample.gui;
q = ~twineSample.gui;
q.parent.alwaysOnTop_(true);
)


~peepers = NodeProxy.audio(s, 2);

(
~peepers[0..4]= {
	arg max=8, note=60;
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,max) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(0,48)*note.cpsmidi, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
};
)
~peepers.play

~peepers[0..2]= nil; //fade out all the crickets!
(
q = ~peepers.gui;
q.parent.alwaysOnTop_(true);
)

~peepers.gui
~peepers[0..10]={nil}
~peepers.removeLast

~b = Buffer.read(s, "audio/whineTRILL.wav".resolveRelative); //resolveRelative finds the file in the same dir as this file
~c = Buffer.read(s, "audio/daxHH_4.wav".resolveRelative); //resolveRelative finds the file in the same dir as this file
~d = Buffer.read(s, "audio/skeleton_bones.wav".resolveRelative); //resolveRelative finds the file in the same dir as this file

~b.play
~c.play
~d.play

~frogz = NodeProxy.audio(s, 2); //turn on the node

(
~frogz[0..4]= {
	arg max=8, note=60;
	var frog1, frog2, out, sig, mix, samp;
	samp=~c;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,max) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = PlayBuf.ar(numChannels: samp.numChannels,
		bufnum: samp,
		rate: rrand(1,48)/note.cpsmidi*BufRateScale.kr(samp),
		loop: 1,
	)*frog1*frog2;
	out = Pan2.ar(sig, 1.0.rand2);
	out = out*20;
};
)

~frogz.play

~frogz[0..8]=nil;

(
g = ~frogz.gui;
g.parent.alwaysOnTop_(true);
)




//a little allpass filter reverb fun
(
~reverb= NodeProxy.audio(s, 2);

~reverb[0]=
{
 //use headphones to prevent feedback!
 var sig, local, decay;
 decay = 0.1; //feedback coefficient (keep between 0 - 1)
 sig = ~frogz.ar + ~peepers.ar + ~twine.ar + ~twineSample.ar;
	local = LocalIn.ar(2) + sig.dup;
15.do({ local = AllpassL.ar(local, 0.05, LFNoise1.kr(0.02!2).range(0.001, 0.05), 1) });
 LocalOut.ar(local * decay);
local;
};

~reverb.play;
r = ~reverb.gui;
r.parent.alwaysOnTop_(true);
)

