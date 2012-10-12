# Turn files of musical pieces into spectrograms with
# 50 columns per second from bottom A 55Hz to top A 3520Hz.
#
# Usage: sh mkjpg.sh *.ogg *.mp3 *.wav
# Dumps the spectrograms into the same directory as the audio files

for a
do
	case "$a" in
	*.ogg)	jpgfile="`basename "$a" .ogg`".jpg
		wavfile=mkjpg.wav
		oggdec -o mkjpg.wav "$a" ;;
	*.mp3)	jpgfile="`basename "$a" .mp3`".jpg
		wavfile=mkjpg.wav
		sox "$a" "$wavfile" ;;
	*.wav)	rm -f mkjpg.wav
		ln "$a" mkjpg.wav ;;
	*)	echo "Eh? Ogg MP3 or WAV only." 1>&2
		exit 1
	esac

	make -f "`dirname $0`"/Makefile mkjpg.jpg && mv mkjpg.jpg "$jpgfile"

	#rm mkjpg.wav
done
