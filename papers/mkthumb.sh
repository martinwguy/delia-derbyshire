#! /bin/sh

# Update the thumbnail images from the big versions.
# They are all A4 proportions, either horizontal or vertically orientated.
# We maintain equal area by resizing the shorter dimension to 100 pixels.

mkdir -p thumb toe

for a in `ls maxi`
do
  for mini in thumb toe
  do
   {
    # Recreate thumbnail if it doesn't exist or it is outdated
    if [ \( ! -e "$mini/$a" \) -o \( "maxi/$a" -nt "mini/$a" \) ]; then

        echo "$mini/$a"

	# Find out width and height
	size=`identify "maxi/$a" | sed 's/.* \([1-9][0-9]*\)x\([1-9][0-9]*\) .*/\1 \2/'`
	# and if we succeeded in finding it, output it.
	case "$mini" in
	    thumb) minsize=133;; # Set length of longest dimension of nail.
	    toe)   minsize=266;;
	esac

	width=`echo "$size" | awk '{ print $1 }'`
	height=`echo "$size" | awk '{ print $2 }'`
	if [ "$width" -gt "$height" ]; then
	    # Landscape: resize to 100 pixels high (x133 wide)
	    convert -resize ${minsize}x "maxi/$a" "$mini/$a"
	else
	    # Square or portrait: resize to 100 wide.
	    convert -resize x${minsize} "maxi/$a" "$mini/$a"
	fi
    fi
   } &
   wait
  done
done
