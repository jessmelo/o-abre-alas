// open file, read and put strings into array, close file.
(

x = CSVFileReader.read(PathName(thisProcess.nowExecutingPath).pathOnly ++ "o abre alas.csv").postcs;
y = CSVFileReader.read(PathName(thisProcess.nowExecutingPath).pathOnly ++ "o abre alas2.csv").postcs;

~extrai_melodia = { |csv, column|
    csv
	   .select { |row| row[column].notNil }
	   .collect { |row| row[column] }
};

~extrai_midi = { |csv|
    var dict = IdentityDictionary.new;

	csv
	.select { |row| row[6].notNil }
	.select { |row| row[2].notNil }
	.select { |row| row[5].notNil }
    .do { |row|
        var time = row[6].asFloat;
        var note = row[2].asInteger;
        var dur  = row[5].asFloat;

        if(dict[time].isNil) {
            dict[time] = (
                notes: [note],
                dur: dur
            );
        } {
            dict[time].notes = dict[time].notes.add(note);
        };
    };

    dict
};

)


(

// melodia principal
~midi_notes = ~extrai_melodia.(x, 2).collect(_.asInteger);
~durs = ~extrai_melodia.(x, 5).collect(_.asFloat);


// melodia principal
~melodia_tudo = ~extrai_midi.(x);
~mel_tempos = ~melodia_tudo.keys.asArray.sort;

~melodia = ~mel_tempos.collect { |t|
    ~melodia_tudo[t].notes
};

~mel_durs = ~mel_tempos.collect { |t|
    ~melodia_tudo[t].dur
};


// acordes
~acordes_tudo = ~extrai_midi.(y);
~tempos = ~acordes_tudo.keys.asArray.sort;

~acordes = ~tempos.collect { |t|
    ~acordes_tudo[t].notes
};

~acordes_dur = ~tempos.collect { |t|
    ~acordes_tudo[t].dur
};

~bpm = TempoClock.new(82/60).permanent_(true);

~melodia_player = Pbind(
   \instrument, \pluckString,
	\midinote, Pn(Pseq(~melodia, 1), Pseq(~melodia.slide(3,1), 1), inf),
    \dur,      Pseq(~mel_durs, inf),
	\white,    Pseq([0.4, 0.2, 0.1, 0.5, 0], inf),
	\ctranspose, [0, -12],
	\excite, 0.4, // constant, safe
    \amp, Pseq([
        Pseries(0, 0.02, 36),  // fade-in once
        Pn(0.6, inf)
    ], 1)
).reset.play(~bpm);

~chords = Pbind(
	\instrument, "saw-gliss",
	\midinote, Pn(Pseq(~acordes, 1), inf),
	\dur,      Pseq(~acordes_dur, inf),
	\amp,      0.6
).play(~bpm);

)

(
	~bpm.schedAbs(~bpm.nextBar, { ~bpm.beatsPerBar_(2) });  // 2 batidos por cp
{
	~chords.reset.play(~bpm);
	16.wait;

	~melodia_player.reset.play(~bpm);

	36.wait;

	~chords.reset.stop;
	~melodia_player.reset.stop;
}.fork(~bpm);
)
