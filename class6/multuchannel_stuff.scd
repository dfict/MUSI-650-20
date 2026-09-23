//some other crap
(w = {var pitch = exprand(70, 4000);
	SinOsc.ar([(rand(200,300)), (exprand(200,300)), 400, 600])*0.5}.scope)


(w = {var pitch = exprand(70, 4000);
	SinOsc.ar(Array.fib(5, 100, 400.rand))*0.5}.scope)

Array.fill(4, Pxrand([0, 1, 2], inf).iter);


(w = {var pitch = exprand(70, 4000);
	SinOsc.ar(Array.exprand(5, 40, 3000).round)*0.1}.scope)

//alternative...in mono

(w = {var pitch = exprand(70, 4000);
	Mix.new(SinOsc.ar(Array.exprand(5, 40, 3000))*0.1)}.scope)



Array.exprand(5, 10, 3000).round;//