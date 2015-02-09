#! /bin/bash

# Make HTML wrappers for the huge images
# giving "<Previous" "^Index^" and "Next>" links at top and bottom

rm -rf html
mkdir -p html

prev= curr= next=
for a in `ls maxi` ''
do
    prev=$curr curr=$next next=`basename $a .jpg`
    if [ "$curr" ]; then
    {
	echo '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">'
	echo "<HTML><HEAD><TITLE>$curr</TITLE></HEAD><BODY>"

	indexline=$(
	echo '<TABLE BORDER=0 CELLSPACING=0 CELLPADDING=0 WIDTH="100%" ALIGN=CENTER>'
	echo -n "<TR><TD ALIGN=LEFT>$curr<TD ALIGN=CENTER>"
	[ "$prev" ] && echo "<A HREF=\"$prev.html\" accesskey=p>&lt;-Prev</A>"
	# Return to index link positions them at the current image in the page
	echo "<A HREF=\"../index.html#$curr\">^Index^</A>"
	[ "$next" ] && echo "<A HREF=\"$next.html\" accesskey=n>Next-></A>"
	echo "<TD ALIGN=RIGHT>$curr</TABLE>"
	)

	echo "<DIV ALIGN=CENTER>"
	echo "$indexline"
	echo "<IMG SRC=\"../maxi/$curr.jpg\" ALT=$curr>"
	echo "$indexline"
	echo "</DIV>"

	echo '</BODY></HTML>'
    } > html/"$curr".html
    fi
done
