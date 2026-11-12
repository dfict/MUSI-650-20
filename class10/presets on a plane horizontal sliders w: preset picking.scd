/*
This program places presets on a plane and uses a neural net to interpolate between those settings.
It needs the Flucoma package.
The gui consists of a cvsliders and slider2d and a set of buttons.
When the window has focus, the shift key activates the Add Point button and stores current
cvsliders values at the point of the slider2d.
The control key activates 'predicting' which is when the neural net controls interpolation
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
	(
{
	var cvs = Buffer.alloc(s,10);							//  synth control values set by a gui or nn
	var presets = FluidDataSet(s);							// a collection of controlValue sets
	var presetPlane = FluidDataSet(s);					// a buffer that maps xy locations to setting indices
	var xy = Buffer.alloc(s,2);								// xy position on the presetPlane
	var nn;																	// the neural network
	~predicting = false;										// when true, the nn sets cvs
	 nn = FluidMLPRegressor(s,
		[7],
		activation:FluidMLPRegressor.sigmoid,
		outputActivation:FluidMLPRegressor.sigmoid,
		maxIter: 1000,
		learnRate:0.1,
		batchSize:1,
		validation: 0
	);

	// the basic UI
	~setCVs = { | vals | cvs.setn(0, vals) };						// set cvs from the language

	~cvs = { FluidBufToKr.kr(cvs) };									// read cvs into a synth

	~setXY = { |x, y| xy.setn(0,[x,y]) };

	~dumpPresets = { |func| presets.dump(func) };
	~dumpPresetPlane = { |func| presetPlane.dump(func) };

	~updateNN = {	| gui |													// when 'predicting' xy  determines the cvs
		if(~predicting){
			nn.predictPoint(xy,cvs,											// ask the nn to 'predict' a setting
				{
				cvs.getn(0,10,{ | newPreset |							// get the setting and write it to the gui
					if (gui.notNil) { defer{ gui.value_(newPreset)} }
				});
			});
		}
	};

	~addAPoint = {
		var counter = 0;
			{ |v|
			var id = "point-%".format(counter);
			presetPlane.addPoint(id,xy);
			presets.addPoint(id,cvs);
			counter = counter + 1;
			if (v.value ==1) { defer({v.value = 0}, 0.3) };
			}
	}.value;

	~nnTrain = 	 { |dispFunc|
			dispFunc = dispFunc ? { | loss| loss.postln };
			nn.fit(presetPlane,presets, dispFunc)
	};

	~nn = nn;
	~presetPlane = presetPlane;

	}.value);

({
	var cvsliders, win, xyslider, button, buttons;
	win = Window("Presets on a Plane", Rect(10, 10, 840, 320)).front;

		//this function looks for if any key has been pressed!
	win.view.keyDownAction = { | v, char, mod |
			// mod.postln;
		if(mod & 131072 !=0) {~predictingButton.valueAction = 1};	// shift activates interpolation
		if(mod & 262144 !=0) {~addButton.valueAction= 1 };				// control saves a setting
		~myKBD.value(char); //about pressing 1 through 10 for presets 1 thru 10
	};

	win.view.keyUpAction = { | v, char, mod |
				if(mod & 131072 ==0)  {~predictingButton.valueAction = 0 };
	};

	cvsliders = MultiSliderView()
		.indexIsHorizontal_(false)
		.maxWidth_(200)
		.elasticMode_(1)
		.isFilled_(1)
		.value_(0.5.dup(10))
		.action_({| ms | ~setCVs.(ms.value) })
		;

	xyslider = Slider2D()
		.action_{ | view |
		~setXY.(view.x, view.y);
		~updateNN.(cvsliders);
		};

	// little macro to get rid of redundant typing
	button = { | name | Button().states_([[name]]) };

	buttons = [
	~presetPopUp = PopUpMenu()
			.action_({ | p |
				p.item !? { | item |
					var xy = ~cvPoints[item].postln;
					xyslider.x = xy[0];
					xyslider.y = xy[1];
					cvsliders.valueAction = ~cvPresets[item].postln;
				};
			}),

	~addButton = Button()
		.states_([
			["Add Preset @ XY", Color.black, Color.white],
			[ "Preset Added", Color.black, Color.green],

		])
		.action_( { |v|

			~addAPoint.(v) ;						// this evaluates the second level of a closure
			 {
				~dumpPresets.( { | c |
					~cvPresets = c["data"]
				});
				 s.sync;
				~dumpPresetPlane.( { | c |
					defer { ~presetPopUp.items = c["data"].keys.asArray.sort;
					~cvPoints = c["data"];
						};
				});
				}.fork(AppClock)
			}),


		button.("Save Presets")
		.action_({
			FileDialog({
				arg folder;
				folder.postln;
				~presetPlane.write(folder+/+"presetPlane.json");
				~presets.write(folder+/+"presets.json");
			},{},2,0,true);
			}),

		button.("Load Presets")
		.action_{
			FileDialog({
				arg folder;
				~presetPlane.read(folder+/+"presetPlane.json");
				~presets.read(folder+/+"presets.json");
			},fileMode:2,acceptMode:0,stripResult:true);
		},

		button.("Train").action_(defer { ~nnTrain .()}),

		button.("Save training")
		.action_{
			Dialog.savePanel({ | path |
				if(PathName(path).extension != "json"){
					path = "%.json".format(path);
				};
				~nn.write(path);
			});
		},

		button.("Load training")
		.action_{
			Dialog.openPanel({ | path |
				~nn.read(path);
			});
		},

	~predictingButton = Button()
		.states_([["Not Predicting"],["Predicting"]])
		.action_({ |v| ~predicting = v.value.asBoolean }),
	];
	win.layout =
		VLayout(
			HLayout(xyslider, VLayout(*buttons)),
			HLayout(
				VLayout(*
					[\FBK1, \FREQ1, \LEVEL1, \CUTOFF1, \Q1,  \FBK2, \FREQ2, \LEVEL2, \CUTOFF2, \Q2]
					.collect({ |n|
					StaticText().string_(n).font_(Font("Osaka", 14)).maxHeight_(12).maxWidth_(70)
				}) ),
				[cvsliders.maxWidth_(1000).maxHeight_(260), width: 3])
		);
	s.sync;
}.value);

(
	~np = NodeProxy.audio(s,2).play;
		~np[0]  = { |amp = 1|
		var val;
		var osc1, osc2, feed1, feed2, base1=69, base2=69, base3 = 130, loud1, loud2;
		var fbk1, freq1, level1, cutoff1, q1,  fbk2, freq2, level2, cutoff2, q2;

		val = ~cvs.();
		#fbk1, freq1, level1, cutoff1, q1,  fbk2, freq2, level2, cutoff2, q2 = val;
		#feed2, feed1 = LocalIn.ar(2);

		loud1 = FluidLoudness.kr(feed1,[\loudness],1,0,hopSize:64);
		loud2 = FluidLoudness.kr(feed2,[\loudness],1,0,hopSize:64);

		osc1 = SinOsc.ar((((feed1 * fbk1) +  freq1) * base1).midicps,mul:(level1* 50).dbamp).atan;
		osc1 = RLPF.ar(osc1,(base3-(cutoff1*(loud2.clip(-120,0)+120))).lag(128/44100).midicps,1 - q1 + 0.01);

		osc2 = SinOsc.ar((((feed2 * fbk2) +  freq2) * base2).midicps,mul: (level2 * 50).dbamp).atan;
		osc2 = MoogFF.ar(osc2,(base3-(cutoff2*(loud1.clip(-120,0)+120))).lag(128/44100).midicps,q2*3.5);

		Out.ar(0,LeakDC.ar([osc1,osc2]*amp,mul:0.1));
		LocalOut.ar([osc1,osc2]);
	};

)
};
)
~np.gui
~np.play

~myKBD = {|char|
	case
	{char == $1}{~np.set(\amp,0)}
	{char == $2}{~np.set(\amp,0.1)}
	{char == $3}{~np.set(\amp,0.3)}
	{char == $4}{~np.set(\amp,0.5)}
	{char == $5}{~np.set(\amp,1)}
	{char == $6}{~np.set(\amp,2)}
};
	//how about soundfile playback! use different buffer numbers and keys select different bumfums!
	//keeping the synthesis function the same.

	