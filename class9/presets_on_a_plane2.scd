/*
Presets on a Plane: places presets on an XY plane and uses a neural net (FluCoMa MLP)
to interpolate between them. Requires FluCoMa 1.0.9+ with SuperCollider 3.14.

How to use (with the window focused):
  1. Move the multislider to make a sound.
  2. Move the XY pad to a spot, then click "Add Preset @ XY" (or press Control).
     Add at least 3-4 presets at different spots.
  3. Click "Train" several times until the printed loss gets small.
  4. Hold Shift (or toggle "Predicting") and move the XY pad to interpolate.

Save/load presets and trainings with the buttons. Different trainings of the
same presets give different results, so try several.

10 settings for two interacting channels of FM feedback:
  fbk1, freq1, level1, cutoff1, q1  (RLPF)
  fbk2, freq2, level2, cutoff2, q2  (MoogFF)
*/

// s.options.device = "QU-32 Audio";   // uncomment when the QU-32 is connected

(
Window.closeAll;
s.waitForBoot {
	var cvs = Buffer.alloc(s, 10);          // synth control values, set by the GUI or the nn
	var xy = Buffer.alloc(s, 2);            // xy position on the plane
	var presets = FluidDataSet(s);          // control-value sets
	var presetPlane = FluidDataSet(s);      // xy location for each preset
	var nn = FluidMLPRegressor(s,
		[7],
		activation: FluidMLPRegressor.sigmoid,
		outputActivation: FluidMLPRegressor.sigmoid,
		maxIter: 1000,
		learnRate: 0.1,
		batchSize: 1,
		validation: 0
	);

	s.sync;

	~predicting = false;   // when true, the nn sets cvs
	~trained = false;      // nn can only predict after training (or loading a training)
	~numPoints = 0;        // number of presets added
	~nn = nn;
	~presets = presets;
	~presetPlane = presetPlane;

	~setCVs = { |vals| cvs.setn(0, vals) };
	~cvs = { FluidBufToKr.kr(cvs) };
	~setXY = { |x, y| xy.setn(0, [x, y]) };

	~updateNN = { |gui|
		if(~predicting and: { ~trained }) {
			nn.predictPoint(xy, cvs, {
				cvs.getn(0, 10, { |newPreset|
					if(gui.notNil) { defer { gui.value_(newPreset) } }
				});
			});
		}
	};

	~addAPoint = {
		var counter = 0;
		{ |displayFunc|
			{ |v|
				var id = "point-%".format(counter);
				presetPlane.addPoint(id, xy);
				presets.addPoint(id, cvs);
				counter = counter + 1;
				~numPoints = ~numPoints + 1;
				"Preset % added (% total)".format(id, ~numPoints).postln;
				if(v.value == 1) { defer({ v.value = 0 }, 0.3) };
				presets.dump(displayFunc);
			}
		}
	}.value;

	~nnTrain = { |dispFunc|
		dispFunc = dispFunc ? { |loss| "loss: %".format(loss).postln };
		if(~numPoints < 2) {
			"Add at least 2 presets before training (currently %)".format(~numPoints).warn;
		} {
			nn.fit(presetPlane, presets, { |loss|
				~trained = true;
				dispFunc.(loss);
			});
		}
	};

	// ---------- GUI ----------
	defer {
		var multislider, win, xyslider, button, buttons;
		win = Window("Presets on a Plane", Rect(10, 10, 840, 320)).front;

		win.view.keyDownAction = { |v, char, mod|
			if(mod & 131072 != 0) { ~predictingButton.valueAction = 1 };  // Shift: interpolate
			if(mod & 262144 != 0) { ~addButton.valueAction = 1 };         // Control: add preset
		};

		win.view.keyUpAction = { |v, char, mod|
			if(mod & 131072 == 0) { ~predictingButton.valueAction = 0 };
		};

		multislider = MultiSliderView()
			.maxWidth_(200)
			.elasticMode_(1)
			.isFilled_(1)
			.value_(0.5.dup(10))
			.action_({ |ms| ~setCVs.(ms.value) });

		xyslider = Slider2D()
			.action_({ |view|
				~setXY.(view.x, view.y);
				~updateNN.(multislider);
			});

		button = { |name| Button().states_([[name]]) };

		buttons = [
			~addButton = Button()
				.states_([
					["Add Preset @ XY", Color.black, Color.white],
					["Preset Added", Color.black, Color.green]
				])
				.action_(~addAPoint.({ |c| c.postcs })),

			button.("Save Presets").action_({
				FileDialog({ |folder|
					~presetPlane.write(folder +/+ "presetPlane.json");
					~presets.write(folder +/+ "presets.json");
					"Presets saved to %".format(folder).postln;
				}, {}, 2, 0, true);
			}),

			button.("Load Presets").action_({
				FileDialog({ |folder|
					~presetPlane.read(folder +/+ "presetPlane.json");
					~presets.read(folder +/+ "presets.json", {
						~presets.size({ |n|
							~numPoints = n;
							"Loaded % presets".format(n).postln;
						});
					});
				}, fileMode: 2, acceptMode: 0, stripResult: true);
			}),

			button.("Train").action_({ ~nnTrain.() }),

			button.("Save training").action_({
				Dialog.savePanel({ |path|
					if(PathName(path).extension != "json") { path = "%.json".format(path) };
					~nn.write(path);
				});
			}),

			button.("Load training").action_({
				Dialog.openPanel({ |path|
					~nn.read(path, {
						~trained = true;
						"Training loaded".postln;
					});
				});
			}),

			~predictingButton = Button()
				.states_([["Not Predicting"], ["Predicting"]])
				.action_({ |v| ~predicting = v.value.asBoolean })
		];
		win.layout = HLayout(multislider, xyslider, VLayout(*buttons));
	};

	// ---------- synth ----------
	~np = NodeProxy.audio(s, 2).play;
	~np[0] = {
		var osc1, osc2, feed1, feed2, base1 = 69, base2 = 69, base3 = 130, loud1, loud2;
		var fbk1, freq1, level1, cutoff1, q1, fbk2, freq2, level2, cutoff2, q2;

		#fbk1, freq1, level1, cutoff1, q1, fbk2, freq2, level2, cutoff2, q2 = ~cvs.();
		#feed2, feed1 = LocalIn.ar(2);

		loud1 = FluidLoudness.kr(feed1, [\loudness], 1, 0, hopSize: 64);
		loud2 = FluidLoudness.kr(feed2, [\loudness], 1, 0, hopSize: 64);

		osc1 = SinOsc.ar((((feed1 * fbk1) + freq1) * base1).midicps, mul: (level1 * 50).dbamp).atan;
		osc1 = RLPF.ar(osc1, (base3 - (cutoff1 * (loud2.clip(-120, 0) + 120))).lag(128/44100).midicps, 1 - q1 + 0.01);

		osc2 = SinOsc.ar((((feed2 * fbk2) + freq2) * base2).midicps, mul: (level2 * 50).dbamp).atan;
		osc2 = MoogFF.ar(osc2, (base3 - (cutoff2 * (loud1.clip(-120, 0) + 120))).lag(128/44100).midicps, q2 * 3.5);

		LocalOut.ar([osc1, osc2]);
		LeakDC.ar([osc1, osc2], mul: 0.1)   // returned signal is what the proxy plays
	};
};
)
