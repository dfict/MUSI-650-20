// DeJesus_EnsemblePiece.scd
// Ensemble piece by Adrian De Jesus — MUSI 650
//
// HOW TO PLAY:
// 1. Click anywhere in this file.
// 2. Press Cmd+A, then Cmd+Return.
// 3. A window pops up. Click your name.
// 4. Hit the big button to turn your sound on. Turn the knobs.
// 5. Listen to Adrian's box and react to it.
//
// Everything is in F Phrygian Dominant, so nothing can clash.

(
s.waitForBoot {
    var scale, root, noteFreq, parts, openPart, launcher;

    scale = [0, 1, 4, 5, 7, 8, 10]; // F Phrygian Dominant
    root = 41; // F2

    // scale step + octave -> frequency
    noteFreq = { |deg, oct = 0|
        (root + (oct * 12) + scale.wrapAt(deg) + (12 * deg.div(7))).midicps
    };

    // ---------------- SOUNDS ----------------

    // JUDE — Drone
    Ndef(\drone, {
        var freq = \freq.kr(noteFreq.(0, 0), 2);
        var sig = Saw.ar(freq * [1, 1.003, 0.997, 2.002]).sum * 0.2;
        sig = RLPF.ar(sig, \cutoff.kr(500, 0.3), 0.3).tanh;
        Pan2.ar(sig, 0, \amp.kr(0.3, 0.1));
    });

    // CLINTON — Bass pulse
    Ndef(\bass, {
        var trig = Impulse.kr(\rate.kr(1));
        var env = EnvGen.kr(Env.perc(0.01, 0.5), trig);
        var freq = \freq.kr(noteFreq.(0, 0), 0.05);
        var sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.3);
        sig = (sig * 2).tanh * env;
        Pan2.ar(sig, 0, \amp.kr(0.4, 0.1));
    });

    // ELLIOTT — Pad
    Ndef(\pad, {
        var freqs = \freqs.kr([noteFreq.(0, 1), noteFreq.(2, 1), noteFreq.(4, 1)], 1);
        var sig = VarSaw.ar(freqs * LFNoise1.kr(0.3 ! 3).range(0.997, 1.003), 0, 0.4);
        sig = LPF.ar(sig, \cutoff.kr(1200, 0.3));
        Splay.ar(sig, 0.6, \amp.kr(0.25, 0.1));
    });

    // NISHAN — Birds
    Ndef(\birds, {
        var trig = Dust.kr(\rate.kr(3));
        var env = EnvGen.kr(Env.perc(0.005, 0.12), trig);
        var sweep = EnvGen.kr(Env.perc(0.001, 0.08), trig);
        var freq = \pitch.kr(3000) * TExpRand.kr(0.8, 1.3, trig) * (1 + (sweep * 0.6));
        var sig = SinOsc.ar(freq + SinOsc.ar(40, 0, freq * 0.03));
        Pan2.ar(sig * env, TRand.kr(-0.8, 0.8, trig), \amp.kr(0.2, 0.1));
    });

    // JESSE — Frogs (two-part "rib-bit" croaks)
    Ndef(\frogs, {
        var trig = Dust.kr(\rate.kr(1.5));
        var trig2 = TDelay.kr(trig, 0.13); // the "bit" after the "rib"
        var base = \pitch.kr(120) * TRand.kr(0.85, 1.15, trig);
        var env1 = EnvGen.kr(Env([0, 1, 0.6, 0], [0.005, 0.05, 0.04]), trig);
        var env2 = EnvGen.kr(Env([0, 1, 0.6, 0], [0.005, 0.07, 0.06]), trig2);
        var rib = Blip.ar(base * (1 + (env1 * 0.1)), 30) * env1;
        var bit = Blip.ar(base * 1.2 * (1 + (env2 * 0.15)), 30) * env2;
        var sig = rib + bit;
        sig = (BPF.ar(sig, 600, 0.3) * 4) + (BPF.ar(sig, 1600, 0.3) * 2);
        Pan2.ar(sig.tanh, TRand.kr(-0.8, 0.8, trig), \amp.kr(0.3, 0.1));
    });

    // MATTEO — Wind
    Ndef(\wind, {
        var gust = \gust.kr(0.3);
        var cf = \pitch.kr(800, 0.2) * LFNoise2.kr(gust).exprange(0.5, 2);
        var sig = BPF.ar(PinkNoise.ar(1 ! 2), cf, 0.3) * 3;
        sig * LFNoise2.kr(gust * 0.7).range(0.2, 1) * \amp.kr(0.4, 0.1);
    });

    // ANTHONY — Tom
    Ndef(\tom, {
        var trig = Impulse.kr(\rate.kr(0.5)) + \t_hit.tr(0);
        var env = EnvGen.kr(Env.perc(0.005, 0.5), trig);
        var drop = EnvGen.kr(Env.perc(0.001, 0.06), trig);
        var freq = \pitch.kr(110) * (1 + drop);
        var sig = SinOsc.ar(freq) + (BPF.ar(WhiteNoise.ar, 2000, 0.5) * drop * 0.3);
        sig = (sig * 1.5).tanh * env;
        Pan2.ar(sig, 0, \amp.kr(0.4, 0.1));
    });

    // JOSEPH — Bell
    Ndef(\bell, {
        var trig = Impulse.kr(\rate.kr(0.25)) + \t_hit.tr(0);
        var exc = Decay2.ar(K2A.ar(trig), 0.001, 0.01) * PinkNoise.ar(0.3);
        var sig = DynKlank.ar(`[[1, 2.76, 5.4, 8.93], [1, 0.5, 0.3, 0.15], [3, 2, 1, 0.5]],
            exc, \freq.kr(noteFreq.(0, 2)));
        Pan2.ar(sig.tanh, 0, \amp.kr(0.3, 0.1));
    });

    // ---------------- WHO PLAYS WHAT ----------------
    // knobs: [label, parameter, range, optional converter]

    parts = [
        (name: "Jude", role: "Drone", key: \drone, knobs: [
            ["note", \freq, ControlSpec(0, 6, \lin, 1, 0), { |v| noteFreq.(v.asInteger, 0) }],
            ["brightness", \cutoff, ControlSpec(100, 3000, \exp, 0, 500)],
            ["volume", \amp, ControlSpec(0, 1, \amp, 0, 0.3)]
        ]),
        (name: "Clinton", role: "Bass pulse", key: \bass, knobs: [
            ["note", \freq, ControlSpec(0, 6, \lin, 1, 0), { |v| noteFreq.(v.asInteger, 0) }],
            ["speed", \rate, ControlSpec(0.25, 4, \exp, 0, 1)],
            ["volume", \amp, ControlSpec(0, 1, \amp, 0, 0.4)]
        ]),
        (name: "Elliott", role: "Pad", key: \pad, knobs: [
            ["chord", \freqs, ControlSpec(0, 6, \lin, 1, 0),
                { |v| [0, 2, 4].collect { |i| noteFreq.(v.asInteger + i, 1) } }],
            ["brightness", \cutoff, ControlSpec(300, 5000, \exp, 0, 1200)],
            ["volume", \amp, ControlSpec(0, 1, \amp, 0, 0.25)]
        ]),
        (name: "Nishan", role: "Birds", key: \birds, echo: true, knobs: [
            ["how many", \rate, ControlSpec(0.5, 10, \exp, 0, 3)],
            ["pitch", \pitch, ControlSpec(1500, 6000, \exp, 0, 3000)],
            ["volume", \amp, ControlSpec(0, 1, \amp, 0, 0.2)]
        ]),
        (name: "Jesse", role: "Frogs", key: \frogs, knobs: [
            ["how many", \rate, ControlSpec(0.3, 6, \exp, 0, 1.5)],
            ["pitch", \pitch, ControlSpec(60, 400, \exp, 0, 120)],
            ["volume", \amp, ControlSpec(0, 1, \amp, 0, 0.3)]
        ]),
        (name: "Matteo", role: "Wind", key: \wind, knobs: [
            ["gusts", \gust, ControlSpec(0.05, 3, \exp, 0, 0.3)],
            ["pitch", \pitch, ControlSpec(200, 3000, \exp, 0, 800)],
            ["volume", \amp, ControlSpec(0, 1, \amp, 0, 0.4)]
        ]),
        (name: "Anthony", role: "Tom", key: \tom, hit: true, echo: true, knobs: [
            ["speed", \rate, ControlSpec(0, 4, \lin, 0, 0.5)],
            ["pitch", \pitch, ControlSpec(60, 300, \exp, 0, 110)],
            ["volume", \amp, ControlSpec(0, 1, \amp, 0, 0.4)]
        ]),
        (name: "Joseph", role: "Bell", key: \bell, hit: true, echo: true, knobs: [
            ["speed", \rate, ControlSpec(0, 2, \lin, 0, 0.25)],
            ["note", \freq, ControlSpec(0, 6, \lin, 1, 0), { |v| noteFreq.(v.asInteger, 2) }],
            ["volume", \amp, ControlSpec(0, 1, \amp, 0, 0.3)]
        ])
    ];

    parts.do { |p| Ndef(p[\key]).fadeTime = 0.5 };

    // ---------------- EFFECTS ----------------
    // Everyone: reverb ("space"). Birds, tom, bell: delay ("echo").

    parts.do { |p|
        var k = p[\knobs];
        if(p[\echo] == true) {
            Ndef(p[\key])[5] = \filter -> { |in|
                in + CombL.ar(in, 1, 0.375, 3, \echo.kr(0.3))
            };
            k = k.insert(k.size - 1, ["echo", \echo, ControlSpec(0, 0.8, \lin, 0, 0.3)]);
        };
        Ndef(p[\key])[10] = \filter -> { |in|
            FreeVerb2.ar(in[0], in[1], \space.kr(0.2), 0.85, 0.5)
        };
        k = k.insert(k.size - 1, ["space", \space, ControlSpec(0, 1, \lin, 0, 0.2)]);
        p[\knobs] = k;
    };

    // ---------------- GUI ----------------

    openPart = { |p|
        var win, items;
        win = Window(p[\name] ++ " — " ++ p[\role], Rect(200, 200, 100 * p[\knobs].size + 60, 280)).front;

        items = [
            StaticText().string_(p[\name] ++ ": " ++ p[\role]).font_(Font("Helvetica", 22)),
            Button().minHeight_(50)
                .states_([
                    ["OFF — click to start", Color.black, Color.gray(0.8)],
                    ["ON — click to stop", Color.white, Color.green(0.6)]
                ])
                .action_({ |b| if(b.value == 1) { Ndef(p[\key]).play } { Ndef(p[\key]).stop } }),
            HLayout(*p[\knobs].collect { |k|
                var label = k[0], param = k[1], spec = k[2];
                var convert = k[3] ? { |v| v };
                var knob = Knob().fixedSize_(Size(70, 70));
                knob.value = spec.unmap(spec.default);
                knob.action = { |kn| Ndef(p[\key]).set(param, convert.(spec.map(kn.value))) };
                VLayout(StaticText().string_(label).align_(\center), knob)
            })
        ];

        if(p[\hit] == true) {
            items = items.add(
                Button().minHeight_(40).states_([["HIT"]])
                    .action_({ Ndef(p[\key]).set(\t_hit, 1) })
            );
        };

        win.layout = VLayout(*items);
        win.onClose = { Ndef(p[\key]).stop };
    };

    launcher = Window("Pick your instrument", Rect(100, 100, 300, 460)).front;
    launcher.layout = VLayout(
        StaticText().string_("Click your name").font_(Font("Helvetica", 18)),
        *(parts.collect { |p|
            Button().minHeight_(36)
                .states_([[p[\name] ++ " — " ++ p[\role]]])
                .action_({ openPart.(p) })
        } ++ [
            Button().minHeight_(36)
                .states_([["STOP EVERYTHING", Color.white, Color.red(0.7)]])
                .action_({ parts.do { |p| Ndef(p[\key]).stop } })
        ])
    );
};
)
