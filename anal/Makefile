CFLAGS=-g -DPARTIALS

all: run run.pdf

run: run.c
	$(CC) $(CFLAGS) -o $@ $< -lpng -lfftw3 -lsndfile -lm

clean:
	rm -f graph*.png scale*.png partial-*.wav

clean: rm run.{aux,dvi,log}

.SUFFIXES: .pdf .tex

.tex.pdf:
	latex $<
	dvipdf $* $@
	rm run.aux run.dvi run.log
