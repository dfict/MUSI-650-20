(
~playDembow = {
    var clock, drone, hijaz;

    clock = TempoClock(95 / 60);
    ~group = Group.new;
    hijaz = Scale.new([0, 1, 4, 5, 7, 8, 10], 12); // Hijaz maqam

    drone = Synth(\sludgeDrone, [
        amp: 0.16,
        dropTime: clock.beatDur * 16,
        dropLevel: 0.45
    ], ~group);

    Pdef(\kick, Pbind(*[
        instrument: \dembowKick,
        group: ~group,
        dur: 0.25,
        amp: Pseq([1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0], inf) * 0.55,
    ]));

    Pdef(\snare, Pbind(*[
        instrument: \dembowSnare,
        group: ~group,
        dur: 0.25,
        amp: Pseq([0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0], inf) * 0.45,
    ]));

    Pdef(\hat, Pbind(*[
        instrument: \dembowHat,
        group: ~group,
        dur: 0.25,
        amp: Pseq([1, 0.4, 1, 0.4], inf) * 0.12,
    ]));

    Pdef(\bass, Pbind(*[
        instrument: \dembowBass,
        group: ~group,
        scale: Scale.phrygian,
        root: 5,
        octave: 2,
        degree: Pseq([0, 0, 3, 0, 5, 3, 0, 0], inf),
        dur: Pseq([1, 1, 0.5, 0.5, 1, 1, 1, 2], inf),
        amp: 0.4,
    ]));

    Pdef(\pad, Pbind(*[
        instrument: \arabicPad,
        group: ~group,
        scale: hijaz,
        root: 5,
        octave: 4,
        degree: Pseq([0, 2, 4, 0], inf),
        dur: 8,
        legato: 1.3,
        amp: 0.5,
    ]));

    [\kick, \snare, \hat, \bass, \pad].do { |key|
        Pdef(key).play(clock, quant: 8);
    };

    (clock: clock, drone: drone);
};
)

~dembow = ~playDembow.value;

// ~dembow.group.free;
Pdef(\snare, Pbind(*[]));  // stop one pattern individually
 Pdef(\kick, Pbind(*[...]));  // redefine while playing — takes effect next quant