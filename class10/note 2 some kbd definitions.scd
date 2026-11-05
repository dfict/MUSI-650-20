~myKBD = { | char |
	case
	{ char == $1} {~np.set(\amp,0) }
	{ char == $2} {~np.set(\amp,0.1)}
	{ char == $3} {~np.set(\amp,0.3)}
	{ char == $4} {~np.set(\amp,0.7)}
	{ char == $5} {~np.set(\amp,1)}
	{ char == $6} {~np.set(\amp,2)}
	{ char == $,} {~np[100] = {PinkNoise.ar(0.1) * LFSaw.kr(3) } }
	{ char == $/} {~np[100] = nil  }
	{ char == $a} {~presetPopUp.valueAction = 1 }
	{ char == $b} {~presetPopUp.valueAction = 2 }
	{ char == $s} {~presetPopUp.valueAction = 3 }
	{ char == $d} {~presetPopUp.valueAction = 4 }
	{ char == $f} {~presetPopUp.valueAction = 5}
};

// In presets on a plane add the ~myKBD line to have a hook into using the keyboard
win.view.keyDownAction = { | v, char, mod |
			// mod.postln;
		if(mod & 131072 !=0) {~predictingButton.valueAction = 1};	// shift activates interpolation
		if(mod & 262144 !=0) {~addButton.valueAction= 1 };				// control saves a setting
		~myKBD.value(char);
	};

