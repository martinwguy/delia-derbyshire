#! /bin/sh

# run: Convert the spectrogams in James Percival's thesis back into audio,
# a driver program for run.c.
#
# Copyright (c) Martin Guy <martinwguy@gmail.com> 2016.
#
# https://dl.dropboxusercontent.com/u/41104723/71040190-MUSC40110-DeliaDerbyshire.pdf
# http://wikidelia.net/wiki/Delia_Derbyshire's_Creative_Process
# and extract the spectrograms with "pdfimages *.pdf image"
#
# Usage: sh run.sh [options] [filename.png]
# Options:
# --floor N	Noise floor; truncate all amplitudes below -N dB to zero.
# --fps N	interpolate between pixel columns to give N columns per second
# --partials	Tell "run" to dump the first 10 audio frames

set -e		# Exit if anything fails unexpectedly

# Offset of spectrogram graphic in image file (= width of left panel)
groffset=91

# Set noise floor to -N decibels. Leave unset to use full range.
floor=

# Set frames per second to interpolate to
fps=

# Process option flags
while [ $# -gt 1 ]; do
    case "$1" in
    --floor) floor="$2"; shift;;
    --fps) fps="$2"; shift;;
    --partials) partialsflag=--partials;;
    *)	break ;;
    esac
    shift
done

[ "$floor" ] && floorflag="--floor $floor"
[ "$fps" ] && fpsflag="--fps $fps"

(
    echo -n "-73 -13 5 651 28 91 2.25 "
    echo "Fig 0.1 Music of the Brisbane School 2.25s"

    echo -n "-63 -4 5 949 27 91 11 "
    echo "Fig II.4 CDD-1-7-37 2'49\"-3'00\" Water makeup"

    echo -n "-65 -13 257 5882 23 91 2.4 "
    echo "Fig III.2 CDD-1-7-67 4'53.2\"-4'55.6\" Way Out makeup type A - rhythm pattern"

    echo -n "-58 -9 23 515 15 91 2.4 "
    echo "Fig III.3 CDD-1-7-67 4'53.2\"-4'55.6\" Way Out makeup type B - bass pattern"

    echo -n "-69 -9 70 18562 28 97 9 "
    echo "Fig III.4 CDD-1-7-67 7'59\"-8'08\" Way Out makeup type D - upward-trending melody"

    echo -n "-71 -11 23 3914 30 91 12 "
    echo "Fig III.5 CDD-1-7-67 10'39\"-10'51\" Way Out makeup type F - sinewave oscillator"

    echo -n "-67 -9 46 3515 20 91 100 "
    echo "Fig III.7 CDD-1-7-68 1'21\"-2'51\" Pot Au Feu early version"

    echo -n "-73 -13 16 6809 30 91 60 "
    echo "Fig IV.2 Putative synthesis using DD334 calculated partials"

    echo -n "-56 -7 11 6808 30 91 240 "
    echo "Fig IV.3 CDD-1-3-5 0'32\"-4'32\" Lowell"

    echo -n "-71 -12 11 6972 19 91 150 "
    echo "Fig IV.4 CDD-1-6-3 15'54\"-18'26\" Random Together I"

    #echo -n "-73 -0 16 6809 30 91 240 "
    #echo "test"
) | while read dbmin dbmax fmin fmax fmaxat groffset duration filestem
do
    # A single png file as parameter limits processing to that file.
    [ "$1" -a "$1" != "$filestem".png ] && continue

    echo $filestem
    imagefile="$filestem".png
    audiofile="$filestem".wav
    if [ "$floor" ]; then
	audiofile="$filestem"-floor-"$floor".wav
    fi

    # Measure the total size of the graphic in pixels.
    # width includes the width of the legend area on the left while the
    # height of the image is the same as the height of the graph data.
    width=`identify "$imagefile" | sed -n 's/.* \([1-9][0-9]*\)x\([1-9][0-9]*\) .*/\1/p'`
    test "$width" || exit 1
    height=`identify "$imagefile" | sed -n 's/.* \([1-9][0-9]*\)x\([1-9][0-9]*\) .*/\2/p'`
    test "$height" || exit 1

    # Extract frequency scale
    convert "$imagefile" -crop 1x`expr $height - 39 - 20`+32+39 scale$$.png

    # Extract raw spectrogram
    convert "$imagefile" -crop `expr $width - $groffset`x$height+${groffset}+0 graph$$.png

    # Figure out the frequency represented by the top row of pixels.
    # In the Percival spectrograms, the frequency represented by the bottom row
    # of pixels is marked but the highest value marked in the legend is for the
    # pixels row $fmaxat pixels below the top one.
    # To figure out the frequency of the top pixel row, calculate the number of
    # Hz per pixel from the two known points and project this to the top point.
    # The lowest pixel row (at y=height-1) represents $fmin and
    # the $fmaxat-th pixel row represents $fmax so each pixel row represents a
    # band of frequencies (fmax-fmin) / ((height-1)-$fmaxat) Hz wide.
    hz_per_pixel_row=`echo "($fmax - $fmin)/(($height - 1) - $fmaxat)" | bc -l`
    # and the top pixel is $fmaxat pixels above the highest marked frequency
    ftop=`echo "$fmax + $fmaxat * $hz_per_pixel_row" | bc -l`

    ./run $floorflag $fpsflag $partialsflag \
	$dbmin $dbmax $fmin $ftop $duration graph$$.png scale$$.png "$audiofile"

    rm -f graph$$.png scale$$.png
done
