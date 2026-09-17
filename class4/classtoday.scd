~myBuffer = Buffer.read(s,"/Users/danielfishkin/gitprojects/MUSI-650-20/class4/audio/flute_key_click stereo.wav" );

~myBuffer.play

(s.waitForBoot({											// guarantee the server is running
	~files = "audio/*".resolveRelative.pathMatch;			// find files in the folder "audio", which
	~buffers = ~files.collect{ | f | Buffer.read(s, f) };	// load those sounds into  buffers on the server
	s.boot;													// the server, of course,  needs to be running
}));

~buffers[5].play


//setup the node
(
~np = NodeProxy.audio(s,2);
~np.fadeTime=0;
~numChannels=1;
~soundFileIndex=5;
~np.play;
)

~np[1]={PlayBuf.ar(~numChannels, bufnum:~buffers[~soundFileIndex], rate:1.0, loop:1)};

(
~np[1]={
	var audio, rate;
	rate= 8/( {rrand(1,24 ! 10) }); //the power of multichannel expansion!
//rate=1;
//	rate= 8/(8..16).asArray;
//	rate= 0.125*(4,6..8).asArray;
//	rate=0.0125*(2,4..16).asArray;
	audio = Mix.ar(PlayBuf.ar(~numChannels, bufnum:~buffers[~soundFileIndex], rate: rate, loop:1));
	Pan2.ar(audio,0);
};
)

(
~np[1]={
	var audio, rate, m1,m2,m3,m4;
	m1 = MouseX.kr(0.12,4);
	m2 = MouseX.kr(8,1);
	m3 = MouseX.kr(3.12,1.4);
	m4 = MouseX.kr(0.12,3,1);
	rate=0.5/[m1,m2,m3,m4];
	audio = Mix.ar(PlayBuf.ar(~numChannels, bufnum:~buffers[~soundFileIndex], rate: rate, loop:1));
	Pan2.ar(audio,0);
};
)

(
~np[1]={
	var audio, rate;
    rate=1;
	audio = Mix.ar(PlayBuf.ar(~numChannels, bufnum:~buffers[~soundFileIndex], rate: rate, loop:1));
	Pan2.ar(audio,0);
};
)

(
~np[1]={
	var audio, rate;
    rate=1;
	rate= 1/( {rrand(1,24 ! 8) }); //the power of multichannel expansion!
	audio = Mix.ar(PlayBuf.ar(~numChannels, bufnum:~buffers[~soundFileIndex], rate: rate, loop:1));
	audio=audio * Pulse.ar(300);
	Pan2.ar(audio,0);
};
)

~np.play;

~np[1]={nil};



(
s.waitForBoot({
~twine = NodeProxy.audio(s, 2);
~twine[0..1] = { |widefreq = 4.25, lo = 4, hi = 5, attack = 0.1, decay = 0.1 |
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

~twine[0..3]=nil



(

)

(
~kud = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSI-650-20/class4/clint/higginsclint_36341_4950841_higgins-metal-cling-perc.wav");
)

"/Users/danielfishkin/Downloads/sound_submissions/kudler-samples-etude3/kudler-short-samples/kudler-short5-guitarwaver.wav"

(
~buf=Buffer.read(s, "audio/daxCHORD.wav".resolveRelative);
~twineSample = NodeProxy.audio(s, 2);
)

(
~twineSample[0..3] = { |widefreq = 4.25, lo = 4, hi = 5, attack = 0.1, decay = 0.1 |
	var aud, f;
	lo = lo * exprand(1, 200);
	hi = hi * exprand(1, 200);
	f = LFClipNoise.kr(widefreq*rrand(0.1, 4.0)).range(lo/440, hi/440);
	aud = PlayBuf.ar(
		numChannels: ~buf.numChannels,
		bufnum: ~buf,
		rate: f * BufRateScale.kr(~buf),
		loop:1
		) * 0.1 ;
	aud = Linen.kr(abs(Slope.kr(f)), attack, 1, decay) * aud;
	aud.dup;
};
~twineSample.play
)



(
~peepers = NodeProxy.audio(s, 2);
~peepers[0..11]= {
	arg max=8, note=49;
	var frog1, frog2, out, sig, mix;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,max) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;
	sig = SinOsc.ar(rrand(0,48)*note.cpsmidi, 2pi.rand, frog1*frog2);
	out = Pan2.ar(sig, 1.0.rand2);
};
~peepers.play
)

~peepers.gui

~b=Buffer.read(s,"audio/daxHH_4.wav".resolveRelative);


(
~frogz = NodeProxy.audio(s, 2);
~frogz[0..11]= {
	arg max=8, note=49;
	var frog1, frog2, out, sig, mix, samp;
	samp=~b;
	frog1= Mix.ar(SinOsc.ar(exprand(0.3,max) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).max(0);
	frog2= Mix.ar(SinOsc.ar(exprand(6,24) * [rrand(0.7,1.3),1], [2pi.rand,2pi.rand], 0.1)).abs;

	//sig = SinOsc.ar(rrand(0,48)*note.cpsmidi, 2pi.rand, frog1*frog2);

	sig= PlayBuf.ar(numChannels: samp.numChannels,
		bufnum:samp,
		rate: rrand(0,48)/note.cpsmidi*BufRateScale.kr(samp),
		loop:1,
	)*frog1*frog2;
	out = Pan2.ar(sig, 1.0.rand2);
	out=out*20;
};
~frogz.gui
)