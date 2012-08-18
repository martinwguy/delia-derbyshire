.SUFFIXES: .ly .pdf .midi

.ly.pdf:
	lilypond $<

all: LePontMirabeau.pdf MusicToUndressTo.pdf dd081913.pdf \
	dd081955.pdf dd090009.pdf

clean:
	-rm *.pdf *.midi
