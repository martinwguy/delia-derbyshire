#! /bin/sh

# run: Convert the spectrogams in James Percival's thesis back into audio,
# a driver program for run.c.
#
# Copyright (c) Martin Guy <martinwguy@gmail.com> 2016.
#
# https://dl.dropboxusercontent.com/u/41104723/71040190-MUSC40110-DeliaDerbyshire.pdf
# http://wikidelia.net/wiki/Delia_Derbyshire's_Creative_Process
# and extract the spectrograms with "pdfimages *.pdf image"

set -e		# Exit if anything fails unexpectedly

# Offset of spectrogram graphic in image file (= width of left panel)
groffset=91

(
    #echo -n "-63 -4 5 949 27 91 11 "
    #echo "Fig II.4 CDD-1-7-37 2'49\"-3'00\" Water makeup.png"

    #echo -n "-58 -9 23 515 15 91 2.4 "
    #echo "Fig III.3 CDD-1-7-67 4'53.2\"-4'55.6\" Pot au Feu makeup type B.png"

    #echo -n "-69 -9 70 18562 28 97 9 "
    #echo "Fig III.4 CDD-1-7-67 7'59\".8'08\" Pot Au Feu makeup Type D.png"

    #echo -n "-71 -11 23 3914 30 91 12 "
    #echo "Fig III.5 CDD-1-7-67 10'39\"-10'51\" Pot Au Feu makeup Type F.png"

    echo -n "-67 -9 46 3515 20 91 100 "
    echo "Fig III.7 CDD-1-7-68 1'21\"-2'51\" Pot Au Feu early version.png"

    #echo -n "-56 -7 11 6808 30 91 240 "
    #echo "Fig IV.3 CDD-1-3-5 0'32\"-4'32\" Lowell.png"

    #echo -n "-71 -12 11 6972 19 91 150 "
    #echo "Fig IV.4 CDD-1-6-3 15'54\"-18'26\" Random Together I.png"

    #echo -n "-73 -13 16 6809 30 91 60 "
    #echo "test-image.png"

    #echo -n "-73 -0 16 6809 30 91 10 "
    #echo "test.png"

) | while read dbmin dbmax fmin fmax fmaxat groffset duration filename
do
    echo $filename

    # Measure the total size of the graphic in pixels.
    # width includes the width of the legend area on the left while the
    # height of the image is the same as the height of the graph data.
    width=`identify "$filename" | sed 's/.* \([1-9][0-9]*\)x\([1-9][0-9]*\) .*/\1/'`
    height=`identify "$filename" | sed 's/.* \([1-9][0-9]*\)x\([1-9][0-9]*\) .*/\2/'`

    # Extract frequency scale
    convert "$filename" -crop 1x`expr $height - 39 - 20`+32+39 scale$$.png

    # Extract raw spectrogram
    convert "$filename" -crop `expr $width - $groffset`x$height+${groffset}+0 graph$$.png

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

    ./run $dbmin $dbmax $fmin $ftop $duration graph$$.png scale$$.png

    rm -f graph$$.png scale$$.png
done
