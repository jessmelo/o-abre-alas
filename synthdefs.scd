(
SynthDef(\pluckString, { arg out = 0, white = 0, freq = 220, amp = 0.4, decay = 5, coef = 0.095, excite = 0.4;
    var src, exc;

    exc = WhiteNoise.ar(
        mul: XLine.ar(excite, excite * 0.5, 0.02)
    );

    src = Pluck.ar(
		in: exc,
        trig: Impulse.ar(1),
        maxdelaytime: 0.025,
        delaytime: 2 / freq,
        decaytime: decay,
		coef: [coef/4, coef]
    );

	src = src;

	// the envelope controls the excitation moment
    src = src * Env.perc(0.001, decay, 1, curve: -4).ar;
    src = src * Lag.kr(amp, 2); // smooth fade-in SAFE

	DetectSilence.ar(in: src, amp: 0.01, time: 0.04, doneAction: Done.freeSelf);
    Out.ar(out, src ! 2);
}).add;
)

(
SynthDef("aSynth2", { arg out = 0, amp = 0.3, freq = 440, pan = 0;
	var src, env, snd;
	env = Env.perc(
		attackTime: 0.45,
		releaseTime: 0.7,
		level: amp,
		curve: 1
	).kr;
	src = SinOsc.ar(
		freq: freq * [1, 0.99, 1.02, 0.997],
		phase: Saw.ar(freq / 3),
		mul: amp
	);
	src = LPF.ar(src, freq: XLine.ar(80, 500, dur: 1.5, doneAction: Done.freeSelf));
	snd = src * env;
	snd = FreeVerb.ar(
		in: Pan2.ar(Decay.ar(Impulse.ar(1), 0.25, LFCub.ar(1200, 0, 0.1)), LFNoise1.ar(1).range(-1, 1)), // amei
		mix: 0.5, room: 0.8, damp: 0.5
	);
	Out.ar(out, snd);
}).add;
)

(
// roubei da chelsie e adaptei
SynthDef("saw-gliss", { arg freq = 392.00, amp = 0.4, startGliss = 0.9, glissDur = 2.25, gate = 1, pan = 0, att = 0.01, rel = 0.1;
	var snd, env; // variables snd, env
	env = Env.adsr(
		attackTime: att,
		decayTime:  0.5,
		sustainLevel: 0.5,
		releaseTime: rel
	).kr(gate: gate);

	snd = SinOsc.ar(Vibrato.kr(freq, 2, 0.02));

	snd = snd * VarSaw.ar(
		freq: freq,
		mul: Line.ar(start: amp, end: 0.05, dur: glissDur)
	);

	snd = snd * env;
	snd = FreeVerb.ar(snd, room: 0.7);
	snd = Pan2.ar(snd, pan);
	Out.ar(0, snd);

	DetectSilence.ar(in: snd, amp: 0.001, time: 2, doneAction: 2);
}).add;
)
