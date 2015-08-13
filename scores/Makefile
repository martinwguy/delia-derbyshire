.SUFFIXES: .ly .pdf .midi .ogg

.ly.pdf:
	lilypond $<

.ly.midi:
	lilypond $<

.midi.ogg:
	timidity -Ow -o $*.wav $<
	oggenc $*.wav
	rm $*.wav

all: LePontMirabeau.pdf MusicToUndressTo.pdf \
	ThePatternEmerges.pdf \
	AnythingGoes.pdf \
	Ape.pdf \
	FreshAire.pdf \
	dd081913.pdf dd081955.pdf dd090009.pdf

clean:
	-rm -f *.ps *.pdf *.midi *.ogg
