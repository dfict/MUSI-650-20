/*
This program places presets on a plane and uses a neural net to interpolate between those settings.
It needs the Flucoma package.
The gui consists of a cvsliders and slider2d and a set of buttons.
When the window has focus, the shift key activates the Add Point button and stores current
cvsliders values at the point of the slider2d.
The control key activates 'interpolating' which is when the neural net controls interpolation
You need to press the "Train" button a few times to get interpolation.  It prints out an error value.
You can save and reload both settings and trainings.
Different trainings of the same settings will get different results.
So it is worth trying multiple trainings.

There are 10 settings for two interacting channels of fm feedback:
 fbk1 - feedback level
 freq1 - frequency offset
 level1 - loudness
cutoff1 - lowpass cutoff
 q1 - resonance

 fbk2, freq2, level2, cutoff2, q2: basically the same but uses MoogFF rather than RLPF for filtering

Of course, entirely different synth defs could be used.

I will redo this a bit to use ControlSpecs for scaling the neuralnet values



*/

// s.options.device = "QU-32 Audio";

(Window.closeAll;
s.waitForBoot{
	{
		// neural net variables
		var cvs = Buffer.alloc(s,10);							//  synth control values set by a gui or nn
		var presets = FluidDataSet(s);							// a collection of controlValue sets
		var counter = 0;
		var presetPlane = FluidDataSet(s);					// a buffer that maps xy locations to setting indices
		var xy = Buffer.alloc(s,2);								// xy position on the presetPlane
		var nn;																	// the neural network

		var interpolating = false;										// when true, the nn sets cvs
		var updateNN,  getPresets, addAPoint;			//functions that access the nn

		nn = FluidMLPRegressor(s,
			[7],
			activation:FluidMLPRegressor.sigmoid,
			outputActivation:FluidMLPRegressor.sigmoid,
			maxIter: 1000,
			learnRate:0.1,
			batchSize:1,
			validation: 0
		);
~nn = nn;
~counter = counter;
~presets = presets;
		updateNN = {	| gui |		// when 'interpolating' xy  determines the cvs
			if(gui.isNil) {
				nn.predictPoint(xy,cvs);
			} {
				nn.predictPoint(xy,cvs,
					{ cvs.getn(0,10,{ | cVals|	defer({ gui.value_(cVals)}) })  })
			}
		};

		getPresets = {		// get presets from server to lang for display and control

			presets.dump( { | c |
				~cvPresets = c["data"];
				counter = ~cvPresets.size;
			});

			presetPlane.dump( { | c |
				~cvPoints = c["data"];
				defer { ~presetPopUp.items = c["data"].keys.asArray.sort };
			});
		};

		addAPoint = { |v|
				var id = "point-%".format(counter);
				presetPlane.addPoint(id,xy);
				presets.addPoint(id,cvs);
				counter = counter + 1;
				if (v.value ==1) { defer({v.value = 0}, 0.3) };
			};

		// the basic UI
		~cvs = { FluidBufToKr.kr(cvs) };					// link to cvs for synthesis code



		{
			var  win, cvsliders, xyslider, button, buttons, projectPath;
			var interpolatingButton, 					// can be toggled by keyboard
			addButton, 							// can be triggered by keyboard
			errorDisplay;							// where training error is displayed

			projectPath = thisProcess.nowExecutingPath.dirname ;

			win = Window("Presets on a Plane", Rect(10, 10, 840, 320)).front;

			win.view.keyDownAction = { | v, char, mod |
				if(mod & 131072 !=0) {interpolatingButton.valueAction = 1};	// shift activates interpolation
				if(mod & 262144 !=0) {addButton.valueAction= 1 };				// control saves a setting
				~myKBD.(char);
			};

			win.view.keyUpAction = { | v, char, mod |
				if(mod & 131072 ==0)  {interpolatingButton.valueAction = 0 };
			};

			cvsliders = MultiSliderView()
			.indexIsHorizontal_(false)
			.indexThumbSize_(4)
			.maxWidth_(200)
			.elasticMode_(1)
			.isFilled_(1)
			.value_(0.5.dup(10))
			.action_({| ms |
				cvs.setn(0, ms.value) 		// write cvs to server
			});

			xyslider = Slider2D()
			.action_{ | view |
				xy.setn(0,[view.x, view.y]);
				if(interpolating) { updateNN.(cvsliders) };
			};

			// little macro to get rid of redundant typing
			button = { | name | Button().states_([[name]]) };

			buttons = [
				~presetPopUp = PopUpMenu()
				.action_({ | p |
					p.item !? { | item |
						var xy = ~cvPoints[item];
						xyslider.x = xy[0];
						xyslider.y = xy[1];
						cvsliders.valueAction = ~cvPresets[item];
					};
				}),

				addButton = Button()
				.states_([
					["Add Preset @ XY", Color.black, Color.white],
					[ "Preset Added", Color.black, Color.green],

				])
				.action_( { |v|
					if (v.value ==1) {
						addAPoint.(v) ;						// this evaluates the second level of a closure
						getPresets.();
						defer({v.value = 0}, 0.1)
					}
				}),

				button.("Save Presets")
				.action_({
					FileDialog({ | path |
						path = path.split($.);
						presetPlane.write(path[0] ++ ".xys.json");
						presets.write(path[0] ++ ".cvs.json");
					},fileMode: 1,acceptMode:1,stripResult:true, path: projectPath +/+ "cvPresets/");
				}),

				button.("Load Presets")
				.action_{
					FileDialog({ | path |
						path = path.split($.);
						presetPlane.clear;
						presets.clear;
						presetPlane.read((path[0] ++ ".xys.json"));
						presets.read(path[0] ++ ".cvs.json");
						getPresets.();
					},fileMode:1,acceptMode:0,stripResult:true, path: projectPath +/+ "cvPresets/");
				},

				button.("Train").action_({
					nn.fit(presetPlane,presets,
						{ | val |  defer{ errorDisplay.string = "error:" + val.round(0.0001) }
					})
				}),

				errorDisplay = StaticText().maxHeight_(12),

				button.("Save nn")
				.action_{
					Dialog.savePanel({ | path |
						if(PathName(path).extension != "json"){
							path = "%.nn.json".format(path);
						};
						nn.write(path);
					}, path: projectPath +/+ "nnPresets/");
				},

				button.("Load nn")
				.action_{
					Dialog.openPanel({ | path |
						{
							nn.clear;
							s.sync;
							nn.read(path);
						}.fork(AppClock);
					}, path:  projectPath +/+ "nnPresets/");
				},
				button.("Clear nn")
				.action_{
					~nn.clear;
				},
				interpolatingButton = Button()
				.states_([["Not Interpolating"],["Interpolating"]])
				.action_({ |v| interpolating = v.value.asBoolean }),
			];

			//filterRange1, noiseDensity1, noiseTempo1, fbk1, gain1,
			win.layout =
			VLayout(
				HLayout(xyslider, VLayout(*buttons)),
				HLayout(
					VLayout(*[\filterRange1, \noiseDensity1, \noiseTempo1, \q1, \gain1,\filterRange2, \noiseDensity2, \noiseTempo2, \q2, \gain2]
						.collect({ |n |
							StaticText().string_(n).font_(Font("Osaka", 14)).maxHeight_(14).maxWidth_(65).minWidth_(65)
					}) ),
					[cvsliders.maxWidth_(2000).maxHeight_(360), stretch: 8])
			);
			s.sync;
		}.value;

	}.value;


	(
	~np = NodeProxy.audio(s,2).play;
	~np[0] = {
    var filterRange1, noiseDensity1, noiseTempo1, fbk1, gain1,
        filterRange2, noiseDensity2, noiseTempo2, fbk2, gain2;
    var feed1, feed2, filt1, filt2, osc1, osc2, q1, q2;

    #filterRange1, noiseDensity1, noiseTempo1, q1, gain1,
     filterRange2, noiseDensity2, noiseTempo2, q2, gain2 = ~cvs.();

    #feed2, feed1 = LocalIn.ar(2);

    filt1 = LFNoise1.ar(noiseTempo1.linexp(0, 1, 0.05, 5))
                .range(43, filterRange1.linlin(0, 1, 60, 120));     // up to ~8 kHz
	//filt1 = filt1 + (feed1 * fbk1 * 100);
	q1= q1.linlin(0,1,0.02,0.001);
	q2= q2.linlin(0,1,0.02,0.001);
    osc1 = RLPF.ar(Dust.ar(noiseDensity1.linexp(0, 1, 0.5, 40)),
                filt1.clip(20, 130).midicps, q1);
    osc1 = (osc1 * gain1.linlin(0, 1, 0, 0.9));
    filt2 = LFNoise1.ar(noiseTempo2.linexp(0, 1, 0.05, 5))
                .range(43, filterRange2.linlin(0, 1, 60, 120));
	//filt2 = filt2 + (feed2 * fbk2 * 100);
    osc2 = RLPF.ar(Dust.ar(noiseDensity2.linexp(0, 1, 0.5, 40) * 1.8),
                filt2.clip(20, 130).midicps, q2);
    osc2 = (osc2 * gain2.linlin(0, 1, 0, 0.9));

    LocalOut.ar([osc1, osc2]);
	Limiter.ar(LeakDC.ar([osc1, osc2]),0.8);

};
);

	~myKBD = { | char |
		var index;
		index = "qwertyuiop[]asdfghjkl;'zxcvbnm,.".indexOf(char);
		if (index.notNil && {index < ~presetPopUp.items.size}) { ~presetPopUp.valueAction = index};
		index = "123456789".indexOf(char); if (index.notNil) { ~np.vol_(index/9) };
		index = "!@#$%^&*(".indexOf(char); if (index.notNil) { ~np.vol_(index/9) };  // when shift is pressed
	};
}
)


