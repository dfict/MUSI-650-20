// Modified/developed code — dembow/doom loop
// developed from gabberkick

(
SynthDef(\dembowKick, {
    var snd, sub, transient, env;
    sub = SinOsc.ar(Env([65, 38], [0.14], \exp).ar);
    env = Env.perc(0.002, 0.65, curve: -4).ar(doneAction: 2); // <- frees the synth
    sub = sub * env;

    transient = SinOsc.ar(150) * Env.perc(0.0005, 0.015).ar;
    transient = (transient * 4).tanh * 0.08;

    snd = sub + transient;
    Out.ar(\out.kr(0), Pan2.ar(snd, 0, \amp.kr(0.65)));
}).add;

SynthDef(\dembowSnare, {
    var snd, click, body;
    body = BPF.ar(WhiteNoise.ar, 1800, 0.3) * Env.perc(0.001, 0.08).ar(doneAction: 2);
    click = SinOsc.ar(400) * Env.perc(0.0005, 0.02).ar;
    snd = (body * 0.6) + (click * 0.5);
    snd = (snd * 3).tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, 0, \amp.kr(0.45)));
}).add;

SynthDef(\dembowHat, {
    var snd;
    snd = HPF.ar(WhiteNoise.ar, 7500);
    snd = snd * Env.perc(0.0005, \len.kr(0.015)).ar(doneAction: 2);
    Out.ar(\out.kr(0), Pan2.ar(snd, 0, \amp.kr(0.12)));
}).add;

SynthDef(\dembowBass, {
    var snd, freq;
    freq = \freq.kr(60.midicps);
    snd = SinOsc.ar(freq) + (Saw.ar(freq) * 0.45);
    snd = snd * Env.adsr(0.005, 0.05, 0.6, 0.05).ar(2, \gate.kr(1));
    snd = HPF.ar(snd, 35);
    snd = LPF.ar(snd, XLine.kr(2500, 700, 0.1));
    snd = (snd * 2.2).tanh;
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.4)));
}).add;

SynthDef(\sludgeDrone, {
    var snd, freqs, lfo, shimmer, fade;
    freqs = \freq.kr(43.65 * 0.5) * [1, 16/15, 1.5, 2];
    lfo = LFNoise2.kr(0.15).range(0.98, 1.02);
    snd = Mix(Saw.ar(freqs * lfo, 0.25));
    snd = snd + Mix(Saw.ar(freqs * 0.997, 0.2));
    snd = (snd * 2.5).tanh;
    snd = RLPF.ar(snd, LFNoise1.kr(0.1).range(300, 900), 0.6);

    shimmer = Mix(Saw.ar(freqs * 2 * LFNoise2.kr(0.08).range(0.995, 1.005), 0.12));
    shimmer = RLPF.ar(shimmer, LFNoise1.kr(0.2).range(800, 2500), 0.4);
    shimmer = shimmer * SinOsc.kr(0.07).range(0.3, 1.0);

    snd = snd + shimmer;
    snd = snd * Env.asr(4, 1, 4).kr(2, \gate.kr(1));

    fade = EnvGen.kr(Env([1, 1, \dropLevel.kr(0.45)], [\dropTime.kr(10), 3], \sin));
    snd = snd * fade;

    Out.ar(\out.kr(0), Pan2.ar(snd, 0, \amp.kr(0.16)));
}).add;

SynthDef(\arabicPad, {
    var snd, freq, vibrato;
    freq = \freq.kr(220);
    vibrato = SinOsc.kr(4.5, mul: freq * 0.008);
    snd = Saw.ar(freq + vibrato, 0.3) + Saw.ar((freq + vibrato) * 1.003, 0.25);
    snd = snd + (SinOsc.ar(freq * 2) * 0.1);
    snd = LPF.ar(snd, 2200);
    snd = snd * Env.adsr(2, 1, 0.7, 5, curve: \sin).ar(2, \gate.kr(1));
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan.kr(0), \amp.kr(0.22)));
}).add;
)

(
~playDembow = {
    var clock, group, patterns, drone, hijaz;

    clock = TempoClock(95 / 60);
    group = Group.new;
    hijaz = Scale.new([0, 1, 4, 5, 7, 8, 10], 12); // Hijaz maqam

    drone = Synth(\sludgeDrone, [
        amp: 0.16,
        dropTime: clock.beatDur * 16,
        dropLevel: 0.45
    ], group);

    patterns = [
        Pbind(*[
            instrument: \dembowKick,
            group: group,
            dur: 0.25,
            amp: Pseq([1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0], inf) * 0.55,
        ]),
        Pbind(*[
            instrument: \dembowSnare,
            group: group,
            dur: 0.25,
            amp: Pseq([0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0], inf) * 0.45,
        ]),
        Pbind(*[
            instrument: \dembowHat,
            group: group,
            dur: 0.25,
            amp: Pseq([1, 0.4, 1, 0.4], inf) * 0.12,
        ]),
        Pbind(*[
            instrument: \dembowBass,
            group: group,
            scale: Scale.phrygian,
            root: 5,
            octave: 2,
            degree: Pseq([0, 0, 3, 0, 5, 3, 0, 0], inf),
            dur: Pseq([1, 1, 0.5, 0.5, 1, 1, 1, 2], inf),
            amp: 0.4,
        ]),
        Pbind(*[
            instrument: \arabicPad,
            group: group,
            scale: hijaz,
            root: 5,
            octave: 4,
            degree: Pseq([0, 2, 4, 0], inf),
            dur: 8,
            legato: 1.3,
            amp: 0.5,
        ]),
    ];

    patterns.do { |pat| pat.play(clock, quant: 8) };

    (clock: clock, group: group, drone: drone);
};
)

~playDembow.value;

// ~dembow.group.free;
