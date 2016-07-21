CFLAGS=-g

run: run.c
	$(CC) $(CFLAGS) -o $@ $< -lpng -lfftw3 -lsndfile -lm

clean:
	rm -f graph*.png scale*.png audio.wav
