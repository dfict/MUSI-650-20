
// STEP 0!!

//the most BASIC way of playing a soundfile is creating and filling a buffer just like this

~myBuffer = Buffer.read(s, "discLOCATIONofBUFFER")

//click and drag a file into SC so you capture the filepath exactly

~myBuffer = Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSI-650-20/class4/audio/flute_key_click stereo.wav")

//now you can play it!
~myBuffer.play

/* STEP 1:  Download sound files for audio playback from a folder named "audio"
The folder needs to be in the same folder as this file.
*/
(s.waitForBoot({																	// guarantee the server is running
	~files = "audio/*".resolveRelative.pathMatch;			// find files in the folder "audio", which
	~buffers = ~files.collect{ | f | Buffer.read(s, f) };	// load those sounds into  buffers on the server
	s.boot;															// the server, of course,  needs to be running
}));


//you can also create an empty array to hold your buffers
~otherbuffers = Array.new; //if for some reason the array isn't there

// Add buffers to the array directly
~otherbuffers = ~buffers.add(Buffer.read(s, "addfilehere"));
//just keep adding files into the array, they each have different buf numbers



/* STEP 2: Play a sound file
the sound files are in an array named ~buffers.
you select which sound to play as
~buffers[index]
as in ~buffers[0] or ~buffers[1], etc
*/

~buffers[1].play

//set up a node...
(~np = NodeProxy.audio(s,2).play;
~np.fadeTime=0;
~numChannels = 1;				// number of channels in the sound file
~soundFileIndex = 2;				// which sound file in the array ~buffers. use different numbers to select files for sampling
~np.play;
)


~np[1] = {  PlayBuf.ar(~numChannels, bufnum: ~buffers[~soundFileIndex], rate: 1.0, loop: 0) };   	// play once
~np[1] = {
	PlayBuf.ar(~numChannels,
		bufnum: ~buffers[~soundFileIndex],
		rate: 1.0,
		loop: 1)
};   	// loop



~np[1] = nil


//...did you notice the playback pitch was off?
//here's a simple way to fix it.

(~np[1] = {
	PlayBuf.ar(~numChannels,
		bufnum: ~buffers[~soundFileIndex],
		rate: BufRateScale.kr(~buffers[~soundFileIndex]),
		loop: 1);
};)  	// loop

~np.play


// For simplicity, the remaining examples use numbers rather than
// the environment variables~numChannels and ~soundFileIndex
//let's rewrite the function with a few variables


// STEP 3: mess with the rate of playback

(~np[1] = {
	var audio, rate;
	rate = MouseX.kr(0.25, 5, 1);
	audio =	PlayBuf.ar(~numChannels, bufnum: ~buffers[~soundFileIndex],	rate: rate, loop: 1);
	Pan2.ar(audio, 0);
};)	// loop


(
~np[1] =  { 						// normal rate playback
	var audio, rate;
	rate = MouseX.kr(0.1, 10, 1); // use 1 as the third argument for exponential ranging.
	audio = PlayBuf.ar(1, bufnum: ~buffers[~soundFileIndex], rate: rate, loop: 1);
	Pan2.ar(audio, LFTri.kr(rate) ); //pan is doing something cool, do you see?
};
)

(
~np[1] =  { 					// quarter speed - two octaves lower and  4x longer
	var audio, rate;
	rate = 10;
	audio = PlayBuf.ar(1, bufnum: ~buffers[~soundFileIndex], rate: rate, loop: 1);
	Pan2.ar(audio, LFTri.kr(rate) );
};
)

~np[1]= nil

(
~np[1] =  { 					// four rates
	var audio, rate;
	rate = 8/[5,7,20, 30]; //the power of multichannel expansion!
	audio = PlayBuf.ar(1, bufnum: ~buffers[~soundFileIndex], rate: rate, loop: 1);
	Pan2.ar(audio, LFTri.kr(rate) );
};
)

~np.play

(
~np[1] =  { 					// four rates at RANDOM
	var audio, rate;
	rate = 8/({rrand(1, 24)} ! 10); // simple form of writing the array. !4 = 4.dup
	rate.postln;
	audio = PlayBuf.ar(1, bufnum: ~buffers[~soundFileIndex], rate: rate, loop: 1);
	Pan2.ar(audio, LFTri.kr(rate) );
};
)


(
~np[1] =  { 					// MANY integer related rates
	var audio, rate, wek;
	rate = 8/(8..16).asArray; //whoa!!
	audio = PlayBuf.ar(1, bufnum: ~buffers[~soundFileIndex], rate: rate, loop: 1);
	Pan2.ar(audio, LFTri.kr(rate/10) );
};
)

//try multiplication too


8/(8..16).asArray //whoa!!

(3,5..9).asArray // cool!

w=(1,2..10).asArray

q= (1,3..16).asArray //only reports odd intervals!
q= (2,4..16).asArray //only reports only divisible by 4 intervals!
((4..8)*3).asArray

(1..10).asArray; //proper ways to use arrays outside of brackets
w = (1, 2..10);  // different proper ways to use arrays outside of brackets

	~np[1]=0

(
~np[1] =  { 					// four rates
	var audio, rate, m1, m2, m3, m4;
	m1 = MouseX.kr(0.25, 5, 1);
	m2 = MouseX.kr(0.15, 4, 1);
	m3 = MouseX.kr(8, 0.1, 1);
	m4 = MouseX.kr(0.1, 3, 1);
	rate = 2/[m1,m2,m3,m4];
	audio = PlayBuf.ar(1, bufnum: ~buffers[1], rate: rate, loop: 1);
	audio = audio * SinOsc.ar(MouseY.kr(20, 300, 0));		// ring modulation
	Pan2.ar(audio, LFTri.kr(rate) );
};
)


(
// STEP 4: add ring modulation
~np[1] =  { 						// now with ring modulation
	var audio, rate;
	rate = 1/3;
	audio = PlayBuf.ar(1, bufnum: ~buffers[1], rate: rate, loop: 1);
	audio = audio * SinOsc.ar(3);
	Pan2.ar(audio, LFTri.kr(rate) );
};
)
(
~np[1] =  { 					// quarter speed - two octaves lower and  4x longer
	var audio, rate;
	rate = 1/4;
	audio = PlayBuf.ar(1, bufnum: ~buffers[1], rate: rate, loop: 1);
	audio = audio * SinOsc.ar(400);
	Pan2.ar(audio, LFTri.kr(rate) );
};
)
(
~np[1] =  { 					// four rates
	var audio, rate;
	rate = 2/[3,6,12, 1];
	audio = PlayBuf.ar(1, bufnum: ~buffers[1], rate: rate, loop: 1);
	audio = audio * SinOsc.ar(MouseX.kr(20, 300, 0));		// ring modulation
	Pan2.ar(audio, LFTri.kr(rate) );
};
)

// STEP 5: make it crunchy by changing SinOsc to Pulse
(
~np[1] =  { 					// quarter speed - two octaves lower and  4x longer
	var audio, rate;
	rate = 1/4;
	audio = PlayBuf.ar(1, bufnum: ~buffers[1], rate: rate, loop: 1);
	audio = audio * Pulse.ar(300);
	Pan2.ar(audio, LFTri.kr(rate) );
};
)
(
// STEP 6: make it more polite with a low pass filter
~np[1] =  { 					// quarter speed - two octaves lower and  4x longer
	var audio, rate, cutoff, rq;
	rate = 1/4;
	audio = PlayBuf.ar(1, bufnum: ~buffers[1], rate: rate, loop: 1);
	audio = audio * Pulse.ar(300);
	cutoff = 2000;
	rq = 0.1;
	audio = RLPF.ar(audio,cutoff, rq);
	Pan2.ar(audio, LFTri.kr(rate) );
};
)
(
~np[1] =  { 					// four rates
	var audio, rate, cutoff, rq;
	rate = 2/[3,6,12, 1];
	audio = PlayBuf.ar(1, bufnum: ~buffers[1], rate: rate, loop: 1);
	audio = audio * Pulse.ar(400);
	cutoff = LFNoise1.kr(1).range(250, 2000);		// one random cutoff
	rq = 0.1;
	audio = RLPF.ar(audio,cutoff, rq);
	Pan2.ar(audio, LFTri.kr(rate) );
};
)

(
~np[1] =  { 					// four rates
	var audio, rate, cutoff, rq;
	rate = 2/[3,6,12, 1];
	audio = PlayBuf.ar(1, bufnum: ~buffers[1], rate: rate, loop: 1);
	audio = audio * Pulse.ar(400);
	cutoff = LFNoise1.kr([0.2, 0.4, 0.8, 1.6]).range(250, 2000);
	rq = 0.01;														// VERY resonant at cutoff
	audio = RLPF.ar(audio, cutoff, 0.005);		// four random cutoffs
	audio = Limiter.ar(audio, 0.1);
	Pan2.ar(audio,  LFTri.kr(rate) );
};
)

(
~np[1] =  { 					// undertone rates
	var audio, rate, cutoff, rq;
	rate = 2/(2, 3..8);
	audio = PlayBuf.ar(1, bufnum: ~buffers[1], rate: rate, loop: 1);
	audio = audio * Pulse.ar(400);
	cutoff = LFNoise1.kr([0.2, 0.4, 0.8, 1.6]).range(250, 2000);
	rq = 0.01;														// VERY resonant at cutoff
	audio = RLPF.ar(audio, cutoff, 0.005);		//  random cutoffs
	audio = Limiter.ar(audio, 0.1);
	audio = audio * SinOsc.ar(250);
	Pan2.ar(audio,  LFTri.kr(rate) );
};
)


	~np[1]=nil



