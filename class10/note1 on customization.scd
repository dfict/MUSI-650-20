	~np = NodeProxy.audio(s,2).play;
	~np[0]  = { | amp = 1|
		var val;
		var osc1, osc2, feed1, feed2, base1=69, base2=69, base3 = 130, loud1, loud2;
		var fbk1, freq1, level1, cutoff1, q1,  fbk2, freq2, level2, cutoff2, q2;

		val = ~cvs.();
		#fbk1, freq1, level1, cutoff1, q1,  fbk2, freq2, level2, cutoff2, q2 = val; // this is where control values get defined


	// here is how you can convert that 0 to 1 value to a useful range for your synthdef
	freq1 =  freq1.linlin(0, 1, 20, 2000);
	freq1 =  freq1.linexp(0, 1, 20, 2000);