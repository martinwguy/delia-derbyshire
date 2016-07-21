.SUFFIXES: .ly .pdf .midi .ogg

.ly.pdf:
	lilypond $<

.ly.midi:
	lilypond $<

.midi.ogg:
	timidity -Ow -o $*.wav $<
	oggenc --quiet $*.wav
	rm $*.wav

all: pdf ogg

pdf: LePontMirabeau.pdf MusicToUndressTo.pdf \
	ThePatternEmerges.pdf \
	AnythingGoes.pdf \
	Ape.pdf \
	ApeHuntGroupA.pdf \
	Arctic.pdf \
	Clothes.pdf \
	FreshAire.pdf \
	MoogiesBloogies.pdf \
	PseudoFolk.pdf \
	ScienceAndHealth.pdf \
	dd081913.pdf dd081955.pdf dd090009.pdf

ogg: LePontMirabeau.ogg MusicToUndressTo.ogg \
	ThePatternEmerges.ogg \
	AnythingGoes.ogg \
	Ape.ogg \
	ApeHuntGroupA.ogg \
	Arctic.ogg \
	Clothes.ogg \
	FreshAire.ogg \
	MoogiesBloogies.ogg \
	PseudoFolk.ogg \
	ScienceAndHealth.ogg \
	dd081913.ogg dd081955.ogg dd090009.ogg

clean:
	-rm -f *.ps *.pdf *.midi *.ogg
