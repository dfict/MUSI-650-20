/*
This program places presets on a plane and uses a neural net to interpolate between those settings.
It needs the Flucoma package.
The gui consists of a multislider and slider2d and a set of buttons.
When the window has focus, the shift key activates the Add Point button and stores current
multislider at the point of the slider2d.
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

s.options.device = "QU-32 Audio";

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
		{ | displayFunc |
			{ |v|
			var id = "point-%".format(counter);
			presetPlane.addPoint(id,xy);
			presets.addPoint(id,cvs);
			counter = counter + 1;
			presetPlane.print;
			if (v.value ==1) { defer({v.value = 0}, 0.3) };
			presets.dump(displayFunc);
			}
		}
	}.value;

	~nnTrain = 	 { |dispFunc|
			dispFunc = dispFunc ? { | loss| loss.postln };
			nn.fit(presetPlane,presets, dispFunc)
	};

	~nn = nn;

	}.value);

({
	var multislider, win, xyslider, button, buttons;
	win = Window("Presets on a Plane", Rect(10, 10, 840, 320)).front;

	win.view.keyDownAction = { | v, char, mod |
		mod.postln;
		if(mod & 131072 !=0) {~predictingButton.valueAction = 1};	// shift activates interpolation
		if(mod & 262144 !=0) {~addButton.valueAction= 1 };				// control saves a setting
	};

	win.view.keyUpAction = { | v, char, mod |
				if(mod & 131072 ==0)  {~predictingButton.valueAction = 0 };
	};

	multislider = MultiSliderView()
		.maxWidth_(200)
		.elasticMode_(1)
		.isFilled_(1)
		.value_(0.5.dup(10))
		.action_({| ms | ~setCVs.(ms.value) })
		;

	xyslider = Slider2D()
		.action_{ | view |
		~setXY.(view.x, view.y);
		~updateNN.(multislider);
		};

	// little macro to get rid of redundant typing
	button = { | name | Button().states_([[name]]) };

	buttons = [
	~addButton = Button()
		.states_([
			["Add Preset @ XY", Color.black, Color.white],
			[ "Preset Added", Color.black, Color.green],

		])
		.action_(
			~addAPoint.( { | c | c.postcs }) 	// this evaluates the second level of closure
		),


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

	~xyslider = xyslider;
	~multislider = multislider;
	win.layout = HLayout(multislider, xyslider, VLayout(*buttons));

	s.sync;
}.value);

(
	~np = NodeProxy.audio(s,2).play;
	~np[0]  = {
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

		Out.ar(0,LeakDC.ar([osc1,osc2],mul:0.1));
		LocalOut.ar([osc1,osc2]);
	};

)
};
)


(
SynthDef(\mouseXY, {
	var x = MouseX.kr(0, 1, lag: 0.05);
	var y = MouseY.kr(0, 1, lag: 0.05);   // flipped so "up" = up, like the Slider2D
	SendReply.kr(Impulse.kr(60), '/mouseXY', [x, y]);
}).add;

~mouseOn = {
	OSCdef(\mouseXY, { |msg|
		var x = msg[3], y = msg[4];
		~setXY.(x, y);
		~updateNN.(~multislider);           // nn predicts, multislider follows
		defer { ~xyslider.setXY(x, y) };    // move the dot without retriggering
	}, '/mouseXY');
	s.bind { ~mouseSynth = Synth(\mouseXY) };
	defer { ~predictingButton.valueAction = 1 };
};

~mouseOff = {
	~mouseSynth !? { ~mouseSynth.free; ~mouseSynth = nil };
	OSCdef(\mouseXY).free;
	defer { ~predictingButton.valueAction = 0 };
};
)

~mouseOn.();   // play the whole screen as your preset plane
~mouseOff.();  // back to manual
