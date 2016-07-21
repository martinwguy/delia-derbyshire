CFLAGS=-g -DPARTIALS

run: run.c
	$(CC) $(CFLAGS) -o $@ $< -lpng -lfftw3 -lsndfile -lm

clean:
	rm -f graph*.png scale*.png partial-*.wav audio.wav
