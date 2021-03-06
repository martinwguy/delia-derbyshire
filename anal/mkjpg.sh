#! /bin/sh

# Turn files of musical pieces into log-frequency-axis spectrograms.
#
# Usage: sh mkjpg.sh *.ogg *.mp3 *.wav
#
# Dumps the spectrograms into the current directory with the same name
# as the audio files, with "mp3" (or whatever) replaced by ".jpg" (or ".png")
#
#	Martin Guy <martinwguy@gmail.com>, August 2012 - January 2016
#	for http://wikidelia.net

# Assign default values to environment variables
# giving 8x12x9=864 pixels high

: ${SRATE:=44100}
: ${MIN_FREQ_OUT:=27.5}	# A(0)
: ${OCTAVES:=9}		# A(0) to A(9) (14080Hz)
: ${FFTFREQ:=5.625}	# The lowest resolvable frequency and the height of
			# each frequency band in the linear spectrogram.
			# Defaulted to 3.125 until March 2017.
: ${PPSEC:=50}		# Pixel columns per second
: ${PPSEMI:=8}		# Pixels per semitone
# ${PPOCT:=$PPSEMI*12}	# Pixels per octave. If set, overrides PPSEMI.
: ${DYN_RANGE:=100}	# Amplitude of black in dB under 0

export SRATE MIN_FREQ_OUT OCTAVES FFTFREQ PPSEC PPSEMI DYN_RANGE

# Should we leave a png file rather than a jpg?
suffix=jpg

# Should be leave the output file next to the audio file it comes from
# instead of in the current directory?
inplace=false

# To get a grayscaled spectrogram instead of a colored one, set
# grayscale=true
grayscale=

# Output a printer-friendly gram with a light background?
light=

# Run all filenames a parallel jobs?
parallel=false

# Should we overlay the output with black and white lines
# incorrespondence with a piano's black and white keys?
piano=false

# Should we use "sox spectrogram" instead of sndfile-spectrogram?
use_sox=false

# Select one channel only instead of mixing all down?
# Value is numeric: 1=left, 2=right etc.
channel=

# Whistle while we work?
verbose=false

# Options to all invocations of sox
soxopts="--multi-threaded --buffer 131072"

if [ $# = 0 ]; then
	echo "Usage: ./mkjpg.sh [PARAMETERS] [--options] file.{wav,mp3,ogg,flac} ..."
	echo "Parameters:"
	echo "SRATE=44100      Give the sampling rate of the input file (it's not autodetected)"
	echo "MIN_FREQ_OUT=27.5 The frequency at the bottom of the graph in Hz. 27.5 is A(0)" 
	echo "                 The --piano code needs this to be an A to work properly."

	echo "OCTAVES=9        Number of octaves between the bottom and the top of the graph"
	echo "                 MIN_FREQ_OUT=27.5 and OCTAVES=9 give A(0) to A(9) (14080Hz)."
	echo "PPSEC=50         Pixel columns per second in the output file"
	echo "PPSEMI=8         Pixels per semitone in the output file"
	echo "FFTFREQ=5.625    The lowest resolvable frequency and the height of each band"
	echo "                 in the linear spectrogram. Lower values increase frequency"
	echo "                 resolution but smear the output horizontally while"
	echo "                 higher values improve the output's temporal definition but"
	echo "                 decrease the distinction between the lowest frequencies."
	echo "DYN_RANGE=100    Amplitude of black in the output, in dB below maximum volume,"
	echo "                 Larger values brighten the darker areas of the graph."
	echo "                 Smaller values make backround noise less visible."
	echo "--gray           Make a grayscale spectrogram instead of a color-mapped one."
	echo "--light          Make a printer-friendly spectrogram with a light background."
	echo "--piano          Overlay single-pixel black and white horizontal lines to mark"
	echo "                 the position of conventional keyboard tuned to A=440Hz."
	echo "--png            Output a PNG file instead of a JPEG."
	echo "--in-place       Leave the output file next to its audio file instead of"
	echo "                 in the current directory."
	echo "--sox            Use "sox spectrogram" instead of sndfile-spectrogram."
	echo "-l               Analyse only the left channel."
	echo "-r               Analyse only the right channel."
	echo "-v               Verbose mode."
	exit 1
fi

# The next wavfile temp filename that we will use.
# They have to be different for each file so that you can run jobs in parallel.
wav=`tempfile -p mkjpg -s .wav -d .` || {
	echo "Can't create temporary file name" 1>&2
	exit 1
}

for a
do
    case "$a" in
    *=*)    eval "$a"
	    continue
	    ;;
    --gray|--grey)
	    grayscale=true
	    continue
	    ;;
    --light)
	    light=true
	    use_sox=true  # sndfile-spectrogram has no light bg option
	    continue
	    ;;
    --piano)
	    piano=true
	    continue
	    ;;
    --png)  suffix=png
	    continue
	    ;;
    --in-place)
	    inplace=true
	    continue
	    ;;
    --parallel|-j)
	    parallel=true
	    in_background='&'
	    continue
	    ;;
    --sox)  use_sox=true
	    continue
	    ;;
    -l)	    channel=1
	    continue
	    ;;
    -r)	    channel=2
	    continue
	    ;;
    --verbose|-v)
	    verbose=true
	    continue
	    ;;
    -*)	exec $0		# Give help message
	    exit 1
	    ;;
    *.ogg)	outfile="`basename "$a" .ogg`".$suffix
	    rm -f $wav
	    oggdec --quiet -o $wav "$a"
	    ;;
    *.mp3)	outfile="`basename "$a" .mp3`".$suffix
	    rm -f $wav
	    lame --quiet --decode "$a" $wav
	    ;;
    *.flac)	outfile="`basename "$a" .flac`".$suffix
echo "outfile=[$outfile]"
	    rm -f $wav
	    flac -s -d -o $wav "$a"
	    ;;
    *.m4a)	outfile="`basename "$a" .m4a`".$suffix
	    rm -f $wav
	    MPLAYER_VERBOSE=0 mplayer -quiet -noconsolecontrols \
		    -ao pcm:file=$wav "$a" > /dev/null
	    ;;
    *.wav)	outfile=`echo "$a" | sed "s/wav\$/$suffix/"`
	    rm -f $wav		# Our temp file name, not the original!
	    ln -s "$a" $wav
	    ;;
    *)	echo "What's \"$a\"? Ogg, Flac, MP3, M4A or WAV files only." 1>&2
	    exit 1
	    ;;
    esac

    # Turn an audio file into an image file
    (
    $inplace || outfile="`basename "$outfile"`"

    ### Here beginneth what used to be a Makefile

    ## Derived constants

    # Pixel rows per octave. They can set PPOCT or PPSEMI.
    # If PPOCT is set, it overrides PPSEMI, if not, it is
    # calculated from PPSEMI.
    if [ ! "$PPOCT" ]; then
	PPOCT=$(expr "$PPSEMI" \* 12)
    fi
    # Only PPOCT is used below.
    PPSEMI=

    # The frequency of the top row in the output
    # e(l(2) * $OCTAVES) is 2 ^ $OCTAVES with fractional powers.
    MAX_FREQ_OUT=$(echo "e(l(2) * $OCTAVES) * $MIN_FREQ_OUT + 0.5" | bc -l | sed 's/\..*//')

    # Output N octaves at PPOCT pixels per octave.
    # Rounding of result to integer is done crudely
    # by adding 0.5 and dropping all decimals in bc's output
    LOG_HEIGHT=$(echo "l($MAX_FREQ_OUT/$MIN_FREQ_OUT) / l(2) * $PPOCT + 0.5" | bc -l | sed 's/\..*//')

    # LIN_HEIGHT is the height of the graphic, which is half the FFT size
    # hence half the lowest resolvable frequency/spacing of frequency bands.
    # which determines the time and frequency resolutions.
    LIN_HEIGHT=$(echo "$SRATE / $FFTFREQ / 2 + 0.5" | bc -l | sed 's/\..*//')

    MAX_FREQ_IN=$(expr $SRATE / 2)
    MAX_Y_IN=$(expr $LIN_HEIGHT - 1)
    MAX_Y_OUT=$(expr $LOG_HEIGHT - 1)

    # Temporary files:
    # $png - the linear frequency axis spectrogram
    # $map - the distortion map used to make the log freq graph from $png
    # $png - the log-frequency-axis output file which we then convert into
    #	 jpg or png as requested.
    png=/tmp/mkjpg$$.png
    map=/tmp/mkjpg$$-map.png
    pianocmd=/tmp/piano-cmd$$
    # or, if tempfile is available, use that.
    f=`tempfile` && {
	rm $f
	png=`tempfile -p mkjpg -s .png`
	map=`tempfile -p map   -s .png`
	pianocmd=`tempfile -p piano`
    }

    trap "rm -f $wav $png $map $pianocmd" INT QUIT

    # Do we need to do a spectro of one channel only?
    if [ "$channel" ]; then
	# Strip out one channel with sox
	wavmono=`tempfile -p mkjpg-mono -s .wav -d .`
	if sox $soxopts $wav $wavmono remix $channel; then
	    rm $wav
	    wav=$wavmono
	else
	    echo "Sox failed to make a mono audio file." 1>&2
	    rm -f $wav $wavmono
	    exit 1
	fi
    fi

    ### Turn a WAV into a PPM file

    # Find the image width, which depends on the length of the piece.
    width="$( echo "(`soxi -s $wav` / $SRATE) * $PPSEC + 0.5" |
	      bc -l | sed 's/\..*//' )"
    test "$width" || exit 1

    $verbose && {
	    echo "Producing $width x $LIN_HEIGHT spectrogram for"
	    echo "          $width x $LOG_HEIGHT output"
    }

    if [ $use_sox = false ] && sndfile-spectrogram | grep -q log-freq ; then
	# Use built-in log frequency axis if sndfile-spectrogram has it
	test "$grayscale" && grayscale=--gray-scale
	sndfile-spectrogram --dyn-range=$DYN_RANGE --no-border $grayscale \
		--log-freq --min-freq=$MIN_FREQ_OUT --max-freq=$MAX_FREQ_OUT \
		--fft-freq="$FFTFREQ" \
		$wav \
		$width $LOG_HEIGHT $png || {
	    # sndfile-spectrogram failed. Why?
	    if [ $width -gt 32767 ]; then
		echo "mkjpg: image too wide ($width) for sndfile-spectrogram (max 32767). Try --sox" 1>&2
	    # else sndfile-spectrogram has already printed a failure message
	    fi
	    rm -f $wav $png;
	    exit 1;
	}
	rm -f $wav
    else
	# If not, do a linear spectrogram and distort it
	if $use_sox; then
	    test "$grayscale" && grayscale=-m
	    test "$light" && light=-l
	    time sox $soxopts $wav -n spectrogram \
		-x $width -y $LIN_HEIGHT -z $DYN_RANGE \
		-n -r $grayscale $light -o $png
	else
	    test "$grayscale" && grayscale=--gray-scale
	    sndfile-spectrogram --dyn-range=$DYN_RANGE --no-border $grayscale \
		$wav \
		$width $LIN_HEIGHT $png
	fi || { rm -f $wav $png; exit 1; }
	rm -f $wav

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
		$map || { rm -f $png $map; exit 1; }

	# Now apply the displacement map
	# echo "Distorting Y axis..."
	convert \
		-size "$width"x$LOG_HEIGHT xc: \
		$png $map \
		-virtual-pixel White \
		-interpolate Mesh \
		-fx "v.p{i,u[2] * $LIN_HEIGHT}" \
		$png || { rm -f $png $map; exit 1; }
    fi
    rm $map

	### Here endeth what used to be a Makefile

	# Engrave piano keys white and black as single pixel lines over the
	# output image.  We assume that the output frequency ranges starts
	# at an A.
	$piano && {
	    $verbose && echo "Applying piano lines..."
	    maxy="$(expr "$PPOCT" \* "$OCTAVES" - 1)"
	    maxx="$(expr "$(identify -format %w $png)" - 1)"
	    echo -n convert $png -strokewidth 1 > $pianocmd
	    for octave in $(seq 0 "$(expr "$OCTAVES" - 1)")
	    do
		for note in $(seq 0 11)
		do
		    #y="$(expr $maxy - "$PPOCT" \*  $octave + $note \) )"
		    y="$(echo "$maxy - $PPOCT * ($octave + $note / 12) + .5" | \
			bc -l | sed 's/\..*//' )"
		    case $note in
		    0|2|3|5|7|8|10) colour=white ;;
		    *) colour=black ;;
		    esac
		    strokewidth=1
		    case "$octave-$note" in
		    0-10|1-2|1-5|1-8|2-0) strokewidth=3 ;;
		    2-7|2-10|3-2|3-5|3-8) strokewidth=3 ;;
		    esac
		    echo -n " -stroke $colour -strokewidth $strokewidth -draw \"line 0,$y $maxx,$y\"" >> $pianocmd
		done
	    done
	    echo " $png" >> $pianocmd
	    . $pianocmd
	}
	rm -f $pianocmd

	# Convert final image to desired format and filename
	#echo "Converting to final format..."
	case "$outfile" in
	*.png)	
		rm -f "$outfile"
		mv $png "$outfile"
		;;
	*.jpg)
		rm -f "$outfile"
		pngtopnm $png | cjpeg -quality 85 -dct float -optimize -progressive > "$outfile" || \
		convert $png "$outfile"
		rm $png
		;;
	*)	echo "Unknown image suffix in final conversion to \"$outfile\"" 1>&2
		exit 1
		;;
	esac
    ) &
    $parallel || wait

    # The next wavfile temp filename that we will use.
    wav=`tempfile -p mkjpg -s .wav -d .`
done

# tempfile seems to create an empty file
rm -f $wav

$parallel && wait
