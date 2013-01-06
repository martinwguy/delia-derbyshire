#!/bin/sh
# The next line restarts using wish \
exec tclsh $0 ${1+"$@"}

# This takes a list of jpg image file names and displays them one at a time.
# If you press 'r', it rotates the image 90 degrees clockwise
# If you press 'l', it rotates the image 90 degrees anticlockwise
# If you press 'n', it goes to the next file in the argument list.
# Note that it doesn't just rotate the image on the display; it transforms the
# data in the file on disk too.
#
# We may get round to doing lossless cropping next...
#
#	Martin Guy <martinwguy@gmail.com>, 4 April 2010

package require Img

# How to discover the names of other keys...
#bind . <Key> {puts "You pressed the key called \"%K\""}

# Which element of $argv are we displaying?
set argn 0

# How much to scale the image down by for visualization?
set zoom 1

set img [image create photo -file [lindex $argv $argn]]

button .button -image $img -command exit
pack .button 

bind . "l" {rotate_left $img; next $img}
bind . "r" {rotate_right $img; next $img}
bind . "u" {rotate_upside $img; next $img}
bind . "-" {zoom_out $img}
bind . "n" {next $img}
bind . "p" {previous $img}
bind . "q" {exit}

proc next {image} {
	global argv argn
	incr argn
	if { $argn >= [llength $argv] } {
		set argn [expr [llength $argv] - 1]
	} else {
		set filename [lindex $argv $argn]
		$image configure -file $filename
		wm title . $filename
	}
}

proc previous {image} {
	global argv argn
	incr argn -1
	if { $argn < 0 } {
		set argn 0
	} else {
		set filename [lindex $argv $argn]
		$image configure -file [lindex $argv $argn]
		wm title . $filename
	}
}

proc zoom_out {image} {
	set t [image create photo]
	$t copy $image
	$image blank
	$image copy $t -shrink -subsample 2 2
	image delete $t
}

proc system {str} {
    exec sh -c $str        
}

# Rotate the image file in place on disk, then reload the current view
proc rotate_left {image} {
	global argv argn

	set filename [lindex $argv $argn]
	system [subst -novariables {filename="[set filename]"; jpegtran -rotate 270 -opt "$filename" > tmp && mv tmp "$filename"}]
	$image configure -file $filename
}

proc rotate_right {image} {
	global argv argn

	set filename [lindex $argv $argn]
	system [subst -novariables {filename="[set filename]"; jpegtran -rotate 90 -opt "$filename" > tmp && mv tmp "$filename"}]
	$image configure -file $filename
}

proc rotate_upside {image} {
	global argv argn

	set filename [lindex $argv $argn]
	system [subst -novariables {filename="[set filename]"; jpegtran -rotate 180 -opt "$filename" > tmp && mv tmp "$filename"}]
	$image configure -file $filename
}
