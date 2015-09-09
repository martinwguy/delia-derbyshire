#! /bin/sh

# Turn files of musical pieces into log-frequency-axis spectrograms.
#
# Usage: sh mkjpg.sh *.ogg *.mp3 *.wav
#
# Dumps the spectrograms into the current directory with the same name
# as the audio files, with "mp3" (or whatever) replaced by ".jpg" (or ".png")


# Assign default values to environment variables used in Makefile

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
	echo "DYN_RANGE=100    Amplitude of black in the output, in dB below maximum volume."
	echo "--thumb          Give a thumbnail 1/8th of default size."
	echo "--piano          Overlay single-pixel black and white horizontal lines to mark"
	echo "                 the position of conventional keyboard tuned to A=440Hz."
	exit 1
fi

for a
do
	rm -f mkjpg.jpg mkjpg.png

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
	-*)	echo "Usage: $0 [--png] file.{ogg,mp3,wav}" 1>&2
		echo "--png: Leave a png file, not a jpg" 1>&2
		exit 1
		;;
	*.ogg)	outfile="`basename "$a" .ogg`".$suffix
		wavfile=mkjpg.wav
		oggdec -o mkjpg.wav "$a"
		;;
	*.mp3)	outfile="`basename "$a" .mp3`".$suffix
		wavfile=mkjpg.wav
		sox "$a" "$wavfile"
		;;
	*.flac)	outfile="`basename "$a" .flac`".$suffix
		rm -f mkjpg.wav
		flac -d -o mkjpg.wav "$a"
		;;
	*.wav)	outfile="`basename "$a" .wav`".$suffix
		rm -f mkjpg.wav
		ln -s "$a" mkjpg.wav
		;;
	*)	echo "Eh? Ogg MP3 or WAV only." 1>&2
		exit 1
		;;
	esac

	# make -e: environment varibles override settings in Makefile.

	if make -e -f "`dirname $0`"/Makefile mkjpg.$suffix
	then rm -f "$outfile"
             mv mkjpg.$suffix "$outfile"
	else rm -f mkjpg.$suffix
	     exit 1
	fi
	rm -f mkjpg.wav

	# Engrave piano keys white and black as single pixel lines over the
	# output image.  We assume that the output frequency ranges starts
	# at an A.
	$piano && {
	    maxy="$(expr "$PPSEMI" \* "$OCTAVES" \* 12 - 1)"
	    maxx="$(expr "$(identify -format %w "$outfile")" - 1)"
echo "maxx = $maxx, maxy = $maxy"
	    echo -n convert \""$outfile\"" -strokewidth 1 > piano-cmd
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
	    echo " \"$outfile\"" >> piano-cmd
	    sh piano-cmd
	}
done
