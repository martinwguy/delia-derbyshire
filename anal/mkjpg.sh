# Turn files of musical pieces into spectrograms with
# 50 columns per second from bottom A 55Hz to top A 3520Hz.
#
# Usage: sh mkjpg.sh *.ogg *.mp3 *.wav
# Dumps the spectrograms into the same directory as the audio files
#
# Environment variables override the default values in Makefile:
# SRATE=44100
# MIN_FREQ_OUT=55	# A(1)
# OCTAVES=6		# A(1) to A(7) (3520Hz)
# FFTFREQ=6.250	# The lowest resolvable frequency and the height of
#		# each frequency band in the linear spectrogram.
# PPSEC=100     # Pixel columns per second
# PPSEMI=16		# Pixels per semitone
# DYN_RANGE=100	# Amplitude of black in dB under 0

# Should we leave a png file rather than a jpg?
suffix=jpg

for a
do
	rm -f mkjpg.jpg mkjpg.png

	case "$a" in
	--png)	suffix=png
		;;
	-*)	echo "Usage: $0 [--png] file.{ogg,mp3,wav}" 1>&2
		echo "--png: Laave a png file, not a jpg" 1>&2
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
	then mv mkjpg.$suffix "$outfile"
	else rm -f mkjpg.$suffix
	fi
	rm -f mkjpg.wav
done
