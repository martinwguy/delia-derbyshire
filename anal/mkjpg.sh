#! /bin/sh

# Turn files of musical pieces into log-frequency-axis spectrograms.
#
# Usage: sh mkjpg.sh *.ogg *.mp3 *.wav
#
# Dumps the spectrograms into the current directory with the same name
# as the audio files, with "mp3" (or whatever) replaced by ".jpg" (or ".png")


# Assign default values to environment variables

: ${SRATE:=44100}
: ${MIN_FREQ_OUT:=55}	# A(1)
: ${OCTAVES:=6}		# A(1) to A(7) (3520Hz)
: ${FFTFREQ:=6.250}	# The lowest resolvable frequency and the height of
			# each frequency band in the linear spectrogram.
: ${PPSEC:=100}		# Pixel columns per second
: ${PPSEMI:=16}		# Pixels per semitone
: ${DYN_RANGE:=100}	# Amplitude of black in dB under 0

export SRATE MIN_FREQ_OUT OCTAVES FFTFREQ PPSEC PPSEMI DYN_RANGE

# Should we leave a png file rather than a jpg?
suffix=jpg

# Should we overlay the output with black and white lines
# incorrespondence with a piano's black and white keys?
piano=false

# To get a grayscaled spectrogram instead of a colored one, set
# grayscale=--gray-scale
grayscale=

if [ $# = 0 ]; then
	echo "Usage: [PARAMETERS] ./mkjpg.sh [--thumb] [--piano] file.{wav,mpg,ogg,flac} ..."
	echo "Parameters:"
	echo "SRATE=44100      Give the sampling rate of the input file (it's not autodetected)"
	echo "MIN_FREQ_OUT=55  A(1)"
	echo "OCTAVES=6	       Number of octaves between the bottom and the top frequencies"
	echo "                 MIN_FREQ_OUT=55 and OCTAVES=6 gives A(1) to A(7) (3520Hz)."
	echo "PPSEC=100        Pixel columns per second in the output file"
	echo "PPSEMI=16        Pixels per semitone in the output file"
	echo "FFTFREQ=6.250    The lowest resolvable frequency and the height of each"
	echo "                 frequency band in the linear spectrogram."
	echo "                 Lower values increase frequency resolution but"
	echo "                 smear the output horizontally while"
	echo "                 higher values improve the output's temporal definition but"
	echo "                 decrease the distiction between the lowest frequencies."
	echo "                 6.250 means that, at the default settings, there is one pixel"
	echo "                 row in the linear spectrogram for each of the lowest rows"
	echo "                 in the output."
	echo "DYN_RANGE=100    Amplitude of black in the output, in dB below maximum volume,"
	echo "                 Smaller values brighten the darker areas of the graph."
	echo "--gray           Make a grayscale spectrogram instead of a color-mapped one."
	echo "--piano          Overlay single-pixel black and white horizontal lines to mark"
	echo "                 the position of conventional keyboard tuned to A=440Hz."
	echo "--png            Output a PNG file instead of a JPEG."
	echo "--thumb          Give a thumbnail version, 1/8th of default size."
	exit 1
fi

for a
do
	case "$a" in
	--png)	suffix=png
		continue
		;;
	--thumb)	# 1/8th of normal size in each direction
		thumb=true
		PPSEMI=2
		PPSEC=12.5
		export PPSEMI PPSEC
		continue
		;;
	--piano)
		piano=true
		continue
		;;
	--gray|--grey)
		grayscale=--gray-scale
		continue
		;;
	-*)	echo "Usage: $0 [--png] file.{ogg,mp3,wav}" 1>&2
		echo "--png: Leave a png file, not a jpg" 1>&2
		exit 1
		;;
	*.ogg)	outfile="`basename "$a" .ogg`".$suffix
		rm -f mkjpg.wav
		oggdec --quiet -o mkjpg.wav "$a"
		;;
	*.mp3)	outfile="`basename "$a" .mp3`".$suffix
		rm -f mkjpg.wav
		sox "$a" mkjpg.wav
		;;
	*.flac)	outfile="`basename "$a" .flac`".$suffix
		rm -f mkjpg.wav
		flac -d -o mkjpg.wav "$a"
		;;
	*.wav)	outfile="`basename "$a" .wav`".$suffix
		rm -f mkjpg.wav
		ln -s "$a" mkjpg.wav
		;;
	*)	echo "Eh? Ogg, Flac, MP3 or WAV files only." 1>&2
		exit 1
		;;
	esac

	### Here beginneth what used to be a Makefile

	## Derived constants

	# Pixel rows per octave
	PPOCT=$(expr "$PPSEMI * 12")

	# The frequency of the top row in the output
	MAX_FREQ_OUT=$(echo "2 ^ $OCTAVES * $MIN_FREQ_OUT + 0.5" | bc -l | sed 's/\..*//')

	# Output N octaves at PPSEMI pixels per semitone
	# Rounding of result to integer is done crudely
	# by adding 0.5 and dropping all decimals in bc's output
	LOG_HEIGHT=$(echo "l($MAX_FREQ_OUT/$MIN_FREQ_OUT) / l(2) * $PPOCT + 0.5" | bc -l | sed 's/\..*//')

	# LIN_HEIGHT is also the FFT size, which determines the
	# time and frequency resolutions.
	LIN_HEIGHT=$(echo "$SRATE / $FFTFREQ + 0.5" | bc -l | sed 's/\..*//')

	MAX_FREQ_IN=$(expr $SRATE / 2)
	MAX_Y_IN=$(expr $LIN_HEIGHT - 1)
	MAX_Y_OUT=$(expr $LOG_HEIGHT - 1)

# Temporary files:
# mkjpg.png - the linear frequency axis spectrogram
# map.png   - the distortion map used to make the log freq graph from mkjpg.png
# mkjpg.ppm - the log-frequency-axis output file which we then convert into
#	      jpg or png as requested.

	rm -f mkjpg.png map.png mkjpg.ppm

	### Turn a WAV into a PPM file

	# Find the image width, which depends on the length of the piece.
	width="$( echo "(`soxi -s mkjpg.wav` / $SRATE) * $PPSEC + 0.5" |
		  bc -l | sed 's/\..*//' )"
	test "$width" || exit 1

	echo "Producing $width x $LIN_HEIGHT spectrogram for"
	echo "          $width x $LOG_HEIGHT output"
	sndfile-spectrogram --dyn-range=$DYN_RANGE --no-border $grayscale \
		mkjpg.wav \
		$width $LIN_HEIGHT mkjpg.png || { rm -f mkjpg.png; exit 1; }

	rm -f mkjpg.wav

	# Make a displacement map to distort the Y axis with.
	# We calculate a 1-pixel wide one then replicate this across the map.

	# IM 6.7.2 has a bug whereby MAX_Y_OUT<256 moves the analysis window
	# up by one octave, presumably to a bug in -fx's division code.
	# Broken: 6.7.2, 6.7.7
	# Working: 6.7.8, 6.7.9, 6.8.0, 6.9.2
	if [ $MAX_Y_OUT -lt 256 ]; then
	    version="$(convert --version | head -1 | sed 's/^Version: ImageMagick \([^ ]*\) .*/\1/')"
	    case "$version" in
	    6.[123456].*|6.7.[01234567]*)
		echo "You need a newer version of ImageMagick for output less than 256 pixels high."
		echo "You have version $version and the first working version was 6.7.8."
		exit 1 ;;
	    6.7.[89]*) : ok ;;
	    6.*) : ok ;;
 	    esac
	fi

	convert -size 1x$LOG_HEIGHT -depth 16 xc: \
		-fx "freq = $MIN_FREQ_OUT * pow($MAX_FREQ_OUT / $MIN_FREQ_OUT, ($MAX_Y_OUT - j) / $MAX_Y_OUT);
		     yy = $MAX_Y_IN - freq * $MAX_Y_IN / $MAX_FREQ_IN;
		     yy/$MAX_Y_IN" \
		-scale "$width"x$LOG_HEIGHT! \
		map.png || { rm -f mkjpg.png map.png; exit 1; }

	# Now apply the displacement map
	echo "Distorting Y axis..."
	convert \
		-size "$width"x$LOG_HEIGHT xc: \
		mkjpg.png map.png \
		-virtual-pixel White \
		-interpolate Mesh \
		-fx "v.p{i,u[2] * $LIN_HEIGHT}" \
		mkjpg.ppm || { rm -f mkjpg.png map.png mkjpg.ppm; exit 1; }

	rm -f mkjpg.png map.png

	### Here endeth what used to be a Makefile

	# Engrave piano keys white and black as single pixel lines over the
	# output image.  We assume that the output frequency ranges starts
	# at an A.
	$piano && {
	    echo "Applying piano lines..."
	    maxy="$(expr "$PPSEMI" \* "$OCTAVES" \* 12 - 1)"
	    maxx="$(expr "$(identify -format %w mkjpg.ppm)" - 1)"
	    echo -n convert mkjpg.ppm -strokewidth 1 > piano-cmd
	    for octave in $(seq 0 "$(expr "$OCTAVES" - 1)")
	    do
		for note in $(seq 0 11)
		do
		    y="$(expr $maxy - "$PPSEMI" \* \( 12 \* $octave + $note \) )"
		    case $note in
		    0|2|3|5|7|8|10) colour=white ;;
		    *) colour=black ;;
		    esac
		    strokewidth=1
		    case "$octave-$note" in
		    0-10|1-2|1-5|1-8|2-0) strokewidth=3 ;;
		    2-7|2-10|3-2|3-5|3-8) strokewidth=3 ;;
		    esac
		    echo -n " -stroke $colour -strokewidth $strokewidth -draw \"line 0,$y $maxx,$y\"" >> piano-cmd
		done
	    done
	    echo " mkjpg.ppm" >> piano-cmd
	    sh piano-cmd
	    rm -f piano-cmd
	}

	# Convert final image to desired format and filename
	echo "Converting to final format..."
	case "$outfile" in
	*.png)	convert mkjpg.ppm "$outfile" ;;
	*.jpg)	cjpeg -progressive -optimize mkjpg.ppm > "$outfile" ;;
	*)	echo "Unknown image suffix in final conversion" 1>&2
		exit 1 ;;
	esac
	rm -f mkjpg.ppm
done
