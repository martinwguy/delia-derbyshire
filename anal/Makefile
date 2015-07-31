# Makefile for this directory and for mkjpg.sh 
all: logaxis pattern.jpg

logaxis: logaxis.c
	$(CC) $(CFLAGS)-o $@ $< -lm

# Dimensions of the input image

SRATE=44100		# Sample rate of input audio

# The image width is calculated to give PPSEC pixels per second (default 50)

# Dimensions of the output image
# 8 octaves starting at 27.5 is A0-27.5 55 110 220 440 880 1760 3520 7040-A8
MIN_FREQ_OUT:=55
OCTAVES:=6
FFTFREQ:=6.250		# The lowest resolvable frequency and the height of
			# each frequency band in the linear spectrogram.
PPSEC:=100              # Pixel columns per second
PPSEMI:=16		# Pixels per semitone
DYN_RANGE:=100		# Amplitude of black in dB under 0

#
# Derived costants
#

PPOCT:=$(shell expr $(PPSEMI) \* 12)	# Pixel rows per octave

MAX_FREQ_OUT:=$(shell echo 2 ^ $(OCTAVES) \* $(MIN_FREQ_OUT) | bc -l )

# Output N octaves at PPSEMI pixels per semitone
# Rounding of result to integer is done crudely
# by adding 0.5 and dropping all decimals in bc's output
LOG_HEIGHT:=$(shell echo "l($(MAX_FREQ_OUT)/$(MIN_FREQ_OUT)) / l(2) * $(PPOCT) + 0.5" | bc -l | sed 's/\..*//')


# LIN_HEIGHT is also the FFT size, which determines the time and frequency
# resolutions.
LIN_HEIGHT  := $(shell echo $(SRATE) / $(FFTFREQ) | bc -l | sed 's/\..*//')

#
# Derived constants
#
MAX_FREQ_IN := $(shell expr $(SRATE) / 2)
MAX_Y_IN    := $(shell expr $(LIN_HEIGHT) - 1)
MAX_Y_OUT   := $(shell expr $(LOG_HEIGHT) - 1)

# Temporary files:
# mkjpg.png - the linear frequency axis spectrogram
# map.png   - the distortion map used to make the log freq graph from mkjpg.png
# $*.ppm    - the log-frequency-axis output file which we then convert into
#	      jpg or png as requested.

%.ppm: %.wav
	@ rm -f $*.jpg $*.ppm $*.png
	@#
	@# Find the image width, which depends on the length of the piece.
	@# I can't see how to get this into a variable to avoid using a file.
	@ expr \( $(PPSEC) \* `soxi -s $<` + $(MAX_FREQ_IN) \) / $(SRATE) > width
	@#
	@ echo "Producing `cat width` x $(LIN_HEIGHT) spectrogram for"
	@ echo "          `cat width` x $(LOG_HEIGHT) output"
	@sndfile-spectrogram --dyn-range=$(DYN_RANGE) --no-border $< \
		`cat width` $(LIN_HEIGHT) $*.png
	@#
	@# Make a displacement map to distort the Y axis with.
	@# We calculate a 1-pixel wide one then replicate this across the map.
	@#
	@ echo "Making displacement map..."
	@convert -size 1x$(LOG_HEIGHT) -depth 16 xc: \
		-fx "freq = $(MIN_FREQ_OUT) * pow($(MAX_FREQ_OUT) / $(MIN_FREQ_OUT), ($(MAX_Y_OUT) - j) / $(MAX_Y_OUT)); \
		     yy = $(MAX_Y_IN) - freq * $(MAX_Y_IN) / $(MAX_FREQ_IN); \
		     yy/$(MAX_Y_IN)" \
		-scale `cat width`x$(LOG_HEIGHT)! map.png
	@#
	@# Now apply the displacement map
	@#
	@ echo "Distorting Y axis..."
	@convert \
		-size "`cat width`"x$(LOG_HEIGHT) xc: \
		mkjpg.png map.png \
		-virtual-pixel White \
		-interpolate Mesh \
		-fx "v.p{i,u[2] * $(LIN_HEIGHT)}" \
		$*.ppm
	@ rm -f width mkjpg.png map.png

%.png: %.ppm
	@ convert $< $@
	@ rm -f $*.ppm

%.jpg: %.ppm
	@ rm -f $@
	@ cjpeg -progressive -optimize $*.ppm > $@
	@ rm -f $*.ppm

clean:
	rm -f map.png mkjpg.jpg width
