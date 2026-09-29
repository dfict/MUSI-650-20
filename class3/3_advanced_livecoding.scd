s.boot;
p = ProxySpace.new.push;

// a stable output location,
// connected (by .play) to the hardware output
~out = { \in.ar(0!2) }; ~out.play;

// a sawtooth oscillator
~osc = { |freq = 60, amp = 0.1|
    Saw.ar(freq, amp).dup
};

~osc = { |freq = 60, amp = 0.1|
	VarSaw.ar(LFNoise0.ar([LFNoise1.ar(1),LFNoise1.ar(0.5)]).range(20,1000), 0, LFNoise1.ar([4,1.3]).range(0,1.0),LFNoise1.ar([4,1.3]).range(0,1.0),)
};

// connect to output
~osc <>> ~out;

// detune it
~osc = { |freq = 60, amp = 0.1, detun = 1.006|
	Mix(Saw.ar(freq * [1, detun], SinOsc.ar(3))).dup
};

// a filter -- \in.ar(0!2) defines an audio input
~lpf = { |ffreq = 800, rq = 1|
	RLPF.ar(\in.ar(0!2), LFNoise1.ar([0.12,0.91]).range(50,8000), rq)
};

// repatch
~osc <>> ~lpf <>> ~out;

// amp envelope
~eg = { |gt = 1|
    \in.ar(0!2) * EnvGen.kr(
        Env.adsr(0.01, 0.1, 0.6, 0.1),
        gt
    )
};
~lpf <>> ~eg <>> ~out;

// now too quiet
~osc.set(\amp, 0.2);

// run some notes
TempoClock.tempo = 124/60;


//need this patch
(
AbstractPlayControl.proxyControlClasses.put(\psSet, StreamControl);
AbstractPlayControl.buildMethods.put(\psSet, #{ |pattern, proxy, channelOffset = 0, index|
    var space = currentEnvironment;   // the ProxySpace, since it's pushed
    Pchain(
        Pbind(\play, {
            var ev = currentEnvironment;
            var skip = (~skipArgs ? #[]).asArray;
            // keys the pattern supplied, plus freq (derived from midinote/degree)
            var keys = (ev.keys.asArray ++ [\freq]).reject { |k| skip.includes(k) };
            space.envir.do { |px|
                var pairs;
                if(px !== proxy) {
                    pairs = px.controlNames.collect(_.name)
                        .select { |name| keys.includes(name) }
                        .collect { |name| [name, ev[name].value] }
                        .flatten;
                    if(pairs.notEmpty) {
                        px.server.makeBundle(px.server.latency, { px.set(*pairs) });
                    };
                };
            };
        }),
        pattern
    ).buildForProxy(proxy, channelOffset, index)
});
)

~player = \psSet -> Pbind(
    \skipArgs, [\amp],
    \midinote, Pseq([Pn(36, { rrand(3, 8) }), 39], inf),
    \dur, Pwrand([0.25, 0.5], [0.9, 0.1], inf)
);

// filter eg
~ffreq = 400;
~feg = { |t_trig = 1, freqMul = 25|
    var eg = EnvGen.kr(
        Env.perc(0.01, 0.1, level: freqMul),
        t_trig, levelBias: 1
    );
    (~ffreq.kr(1) * eg).clip(20, 20000)
};

// patch the filter envelope to the filter's frequency input
~lpf.set(\ffreq, ~feg);

~feg.set(\freqMul, 40);
~lpf.set(\rq, 0.1);

// change the pattern to accent only some notes
~player = \psSet -> Pbind(
    \skipArgs, [\amp],
    \midinote, Pseq([Pn(36, { rrand(3, 8) }), 39], inf),
    \dur, Pwrand([0.25, 0.5], [0.9, 0.1], inf),
    \t_trig, Pwrand([0, 1], [0.7, 0.3], inf)
);

// we're done, remove everything
p.clear;
p.pop;