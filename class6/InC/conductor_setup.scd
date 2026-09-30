//https://www.youtube.com/watch?v=rdc-uPfkSCQ

//be sure port 20808 is open!
//check firewire settings

// create a synchronized clock
//~clock = LinkClock(2).latency_(Server.default.latency);


// GUI to watch status
(
var win = Window("LinkClock", Rect(200, 200, 500, 100)).front,
peersBox, tempoBox, barsBox, beatsBox,
font = Font.default.copy.size_(32),
boldFont = font.boldVariant,
controller, task;

win.layout = HLayout(
    StaticText().font_(font).string_("Peers:"),
    peersBox = NumberBox().font_(boldFont).align_(\center).fixedWidth_(80),
    StaticText().font_(font).string_("Tempo:"),
    tempoBox = NumberBox().font_(boldFont).align_(\center).fixedWidth_(120),
    StaticText().font_(font).string_("Now:"),
    barsBox = NumberBox().font_(boldFont).align_(\center).fixedWidth_(80),
    beatsBox = NumberBox().font_(boldFont).align_(\center).fixedWidth_(80)
);

[peersBox, barsBox, beatsBox].do { |view| view.enabled_(false) };

~clock = LinkClock(2).latency_(Server.default.latency);

tempoBox.action = { |view| ~clock.tempo = view.value / 60 };
tempoBox.value = ~clock.tempo * 60;
peersBox.value = ~clock.numPeers;

task = Routine {
    var bars, beats;
    loop {
        bars = ~clock.bar;
        beats = ~clock.beatInBar;
        {
            barsBox.value = bars;
            beatsBox.value = beats;
        }.defer(~clock.latency);
        1.0.wait;
    }
}.play(~clock, quant: 1);

controller = SimpleController(~clock)
.put(\tempo, {
    defer { tempoBox.value = ~clock.tempo * 60 }
})
.put(\numPeers, {
    defer { peersBox.value = ~clock.numPeers }
})
.put(\stop, { defer { win.close } });

win.onClose = { task.stop; controller.remove };
)


// changing the tempo in another application should affect tempo in SC
// changing the tempo in SC should affect every connected application
~clock.tempo = 90/60;

//command period should not be used.

// start/stop notifications
// the remote peer should enable start/stop sync
(
q = nil;
c = SimpleController(l)
.put(\linkStart, {
    if(q.isNil) {
        q = Pbind(
            \degree, Pn(Pseries(0, 1, 8), inf),
            \dur, 0.25
        ).play(l, quant: -1);
    }
})
.put(\linkStop, {
    q.stop;
    q = nil;
})
.put(\stop, { c.remove });  // clean up if clock stops
)

p.stop;
r.stop;
l.stop;