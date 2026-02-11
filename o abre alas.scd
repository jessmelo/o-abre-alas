// open file, read and put strings into array, close file.
x = CSVFileReader.read("C:\\Users\\jess_\\Music\\supercollider\\o abre alas.csv").postcs;
y = CSVFileReader.read("C:\\Users\\jess_\\Music\\supercollider\\o abre alas2.csv").postcs;

~extrai_coluna = { |csv, column|
    csv.collect { |row|
		postln(row[column]);
        row[column]
    }
};

(

~midi_notes = ~extrai_coluna.(x, 2).collect(_.asInteger);
~durs = ~extrai_coluna.(x, 5).collect(_.asFloat);

~chords = ~extrai_coluna.(y, 2).collect(_.asInteger);
~durs_chords = ~extrai_coluna.(y, 5).collect(_.asFloat);

~bpm = TempoClock.new(108/60).permanent_(true);

~melodia = Pbind(
    \instrument, \pluckString,
	\midinote, Pn(Pseq(~midi_notes, 1), inf),
	\white, Pseq([0.4, 0.2, 0.1, 0.5, 0], inf),
    \dur,      Pseq(~durs, inf),
    \amp,      0.5
).play(~bpm).stop;

~chords = Pbind(
	\instrument, \pluckString,
	\midinote, Pn(Pseq(~chords, 1), inf),
    \dur,      Pseq(~durs_chords, inf),
    \amp,      0.6
).play(~bpm).stop;

)

(
SynthDef(\pluckString, { arg out = 0, white = 0, freq = 220, amp = 0.4, decay = 10, coef = 0.065;
    var src;

    src = Pluck.ar(
		in: GrayNoise.ar(
			mul: XLine.ar(start: amp - 0.15, end: amp  - (amp / 2), dur: 1)
		),
        trig: Impulse.ar(2),        // no internal trigger — use doneAction OR external event
        maxdelaytime: 1/freq,
        delaytime: 1/freq,
        decaytime: decay,
        coef: coef
    );

	src = src;

	// the envelope controls the excitation moment
    src = src * Env.perc(0.001, decay, 1, curve: -4).ar;

	DetectSilence.ar(in: src, amp: 0.01, time: 0.04, doneAction: Done.freeSelf);
    Out.ar(out, src ! 2);
}).add;
)

(
	~bpm.schedAbs(~bpm.nextBar, { ~bpm.beatsPerBar_(2) });  // 4 batidos por cp
{
	1.wait;
	~melodia.reset.play(~bpm);

	9.wait;
	~chords.reset.play(~bpm);

	24.wait;

	~melodia.reset;

	32.wait;

	~melodia.reset.stop;

	16.wait;
	~chords.reset.stop;
}.fork(~bpm);
)
