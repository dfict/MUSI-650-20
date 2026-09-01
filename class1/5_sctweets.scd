

    about research music


Elliot Kermit Canfield-Dafilou
SC Tweets
short SuperCollider compositions written in 140 charactors or less

//this line is exactly 140 characters long. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .|



//1

{x={Blip.ar(Rand(15,25),SinOsc.ar(Rand(0.5,3),Rand(),Rand(15,50)))}!5;y=Splay.ar(x.value);z=FreeVerb.ar(BHiPass.ar(y,13))}.play;//#sc #1 ekc


//2

{a=XLine.ar([25,30,55,85,140,225,365,580,945,1525,2470],4e2,44);Splay.ar(SinOsc.ar(XLine.ar(0.5,9,45,1,0,2))*BPF.ar(Saw.ar(a),a))}.play//#sc

8 channel surround version

{a=XLine.ar([9,25,27,30,43,55,85,99,140,225,365,580,781,945,1525,2470],4e2,44);SinOsc.ar(XLine.ar(0.5,9,45,1,0,2))*BPF.ar(Saw.ar(a),a)}.play



//3

{a=FreeVerb;b=(1..9);a.ar(a.ar(Splay.ar(Klank.ar(`[b,b.scramble,2],Decay.ar(Dust.ar(b*0.05)),[5,7,8,13,24,37,46].scramble*10))))}.play //#sc

play{a=FreeVerb;b=(1..9);a.ar(a.ar(Splay.ar(Klank.ar(`[b,b.scramble,2],Decay.ar(Dust.ar(b*0.05)),[6,7,9,11,14.6,22,44].scramble*10))))}//#sc


//4

This week's tweet may require allocating more memory to the server: Server.local.options.memSize=2**16;s.reboot;

play{a=PinkNoise.ar*Dust.kr(0.7);b=CuspN.ar*Dust.kr(1);Splay.ar(GVerb.ar(a+b+CombN.ar(a+b,5,{(1..20).choose/5}!5,{(5..15).choose}!9)))}//#sc


//5

play{a=Saw.kr(0.1);Pan2.ar(Gendy1.ar(6,2,1,0.5,LFTri.kr(1,1,20,50),Line.ar(50,250,60,1,0,2),0.5,0.7,20),a+SinOsc.kr(6+a)-Saw.kr(0.05))}//#sc


//6

{a=Impulse.kr(10)!2;b=TChoose;c=b.kr(a,(0..5));MoogFF.ar(Saw.ar(d=Stepper.kr(a,0,b.kr(a,[0,1]),c*5,c,c)*50),d*1.7,3.8)}.play//#SuperCollider


//7

a="Happy Birthday Sarah!!".ascii;r{22.do{|i|x={b=a[i].midicps;LPF.ar(LFTri.ar(b/2),b*0.8)}.play;(c=a[i]/220).wait;x.release(c*2)}}.play//#sc


//8

r{99.do{|i|a=(1..9).midicps*7;x={VarSaw.ar([b=a.choose,b*2+5,b*Rand(1,3)],0,Line.ar([0,1],[1,0],1)).sum!2}.play;1.wait;x.release}}.play//#sc


//9

play{t=Saw.kr([5,5.1]);PlayBuf.ar(1,b=Buffer.read(s,"sounds/a11wlk01.wav"),LFTri.ar(0.3),t,Demand.kr(t,0,Dseq([35,89,57,141,190]*1e3,inf)))}


//10

8 channel surround version

play{a=RLPF.ar(FreeVerb.ar(Saw.ar(Sweep.ar(Dust.ar([1,1,1,1,1,1,1,1]),3)*200),800,1/2));a=Limiter.ar(a+CombN.ar(a,3,Saw.kr(1,0.5)+1,9),0.9)}


//11

8 channel surround version

play{LocalOut.ar(a=Limiter.ar(CombN.ar(BPF.ar(LocalIn.ar(7)*5+Saw.ar([6,9,11,13,20,21,31],0.1),2**LFNoise0.kr(5,3)*300,0.5),3,3,40)),0.9);a}

copyright 2025 EKCD
