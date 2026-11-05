//two moves that we can do for your homework
//adding a control via a keyboard function

//OR change the synthesis function directly
//make your own synthesis function.

~myKBD = {|char|
	case
	{char == $1}{~np.set(\amp,0)}
	{char == $2}{~np.set(\amp,0.1)}
	{char == $3}{~np.set(\amp,0.3)}
	{char == $4}{~np.set(\amp,0.5)}
	{char == $5}{~np.set(\amp,1)}
	{char == $6}{~np.set(\amp,2)}
	{char == $,}{~np[100]={PinkNoise.ar*LFSaw.kr(3)}}
	{char == $/}{~np[100]=nil}
	{char == $a}{~presetPopUp.valueAction=1}
	{char == $s}{~presetPopUp.valueAction=2}
	{char == $d}{~presetPopUp.valueAction=3}
	{char == $f}{~presetPopUp.valueAction=4}
};

[$a,$s,$d,$f]

~presetPopUp.value=1;
//SET a preset

~presetPopUp.valueAction=1
//recall a preset!

~np.play


	//how about soundfile playback! use different buffer numbers and keys select different bumfums!
	//keeping the synthesis function the same.